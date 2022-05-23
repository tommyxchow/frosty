import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/stores/chat_assets_store.dart';
import 'package:frosty/screens/channel/stores/chat_details_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

/// The store and view-model for chat-related activities.
class ChatStore = ChatStoreBase with _$ChatStore;

abstract class ChatStoreBase with Store {
  static const _messageUpperLimit = 7500;
  static const _messageLimit = 5000;

  /// The provided auth store to determine login status, get the token, and use the headers for requests.
  final AuthStore auth;

  /// The provided setting store to account for any user-defined behaviors.
  final SettingsStore settings;

  /// The focus node for the textfield to allow for showing and hiding the keyboard/focus.
  final textFieldFocusNode = FocusNode();

  /// The name of the channel to connect to.
  final String channelName;

  /// The channel's ID for API requests.
  final String channelId;

  /// The channel's display name to show on widgets.
  final String displayName;

  /// The Twitch IRC WebSocket channel.
  WebSocketChannel? _channel;

  // The retry counter for exponential backoff.
  var _retries = 0;

  // The current time to wait between retries for exponential backoff.
  var _backoffTime = 0;

  /// The scroll controller that controls auto-scroll and resume-scroll behavior.
  final scrollController = ScrollController();

  /// The text controller that handles the TextField inputs and sending of messages.
  final textController = TextEditingController();

  /// The chat details store responsible for the chat modes and users in chat.
  final ChatDetailsStore chatDetailsStore;

  /// The assets store responsible for badges, emotes, and the emote menu.
  final ChatAssetsStore assetsStore;

  /// Requested message to be sent by the user. Will only be sent on receipt of a USERNOTICE command.
  IRCMessage? toSend;

  /// The list of chat messages to render and display.
  @readonly
  var _messages = ObservableList<IRCMessage>();

  /// If the chat should automatically scroll/jump to the latest message.
  @readonly
  var _autoScroll = true;

  @readonly
  var _showAutocomplete = false;

  /// The logged-in user's appearance in chat.
  @readonly
  var _userState = const USERSTATE();

  final reactions = <ReactionDisposer>[];

  ChatStoreBase({
    required this.auth,
    required this.chatDetailsStore,
    required this.assetsStore,
    required this.settings,
    required this.channelName,
    required this.channelId,
    required this.displayName,
  }) {
    // Create a reaction that will reconnect to chat when logging in or out.
    // Closing the channel will trigger a reconnect with the new credentials.
    reactions.add(reaction(
      (_) => auth.isLoggedIn,
      (_) => _channel?.sink.close(1001),
    ));

    assetsStore.init();

    _messages.add(IRCMessage.createNotice(message: 'Connecting to chat...'));

    connectToChat();

    // Tell the scrollController to determine when auto-scroll should be enabled or disabled.
    scrollController.addListener(() {
      // If the user scrolls up, auto-scroll will stop, allowing them to freely scroll back to previous messages.
      // Else if the user scrolls back to the bottom edge (latest message), auto-scroll will resume.
      if (scrollController.position.pixels < scrollController.position.maxScrollExtent) {
        if (_autoScroll == true) _autoScroll = false;
      } else if (scrollController.position.atEdge || scrollController.position.pixels > scrollController.position.maxScrollExtent) {
        if (_autoScroll == false) _autoScroll = true;
      }
    });

    // Add a listener to the textfield focus that will hide the emote menu if it is currently shown.
    textFieldFocusNode.addListener(() {
      if (textFieldFocusNode.hasFocus && assetsStore.showEmoteMenu) assetsStore.showEmoteMenu = false;
    });

    // Add a listener to the textfield that will show/hide the autocomplete bar if focused.
    // Will also rebuild the autocomplete bar when typing, refreshing the results as the user types.
    textController
        .addListener(() => _showAutocomplete = textFieldFocusNode.hasFocus && textController.text.split(' ').last.isNotEmpty ? true : false);
  }

  /// Handle and process the provided string-representation of the IRC data.
  ///
  /// If a message, parses the IRC data into an [IRCMessage] and handles it based on the [Command].
  /// Else if a PING request, sends back the PONG to keep the connection alive.
  @action
  void _handleIRCData(String data) {
    // The IRC data can contain more than one message separated by CRLF.
    // To account for this, split by CRLF, then loop and process each message.
    for (final message in data.trimRight().split('\r\n')) {
      // debugPrint(message);
      if (message.startsWith('@')) {
        final parsedIRCMessage = IRCMessage.fromString(message, userLogin: auth.user.details?.login);

        // Filter messages from any blocked users if not a moderator or not the channel owner.
        if (!_userState.mod &&
            channelName != auth.user.details?.login &&
            auth.user.blockedUsers.where((blockedUser) => blockedUser.userLogin == parsedIRCMessage.user).isNotEmpty) continue;

        switch (parsedIRCMessage.command) {
          case Command.privateMessage:
            _messages.add(parsedIRCMessage);
            break;
          case Command.clearChat:
            _messages = IRCMessage.clearChat(messages: _messages, ircMessage: parsedIRCMessage).asObservable();
            break;
          case Command.clearMessage:
            _messages = IRCMessage.clearMessage(messages: _messages, ircMessage: parsedIRCMessage).asObservable();
            break;
          case Command.notice:
          case Command.userNotice:
            _messages.add(parsedIRCMessage);
            break;
          case Command.roomState:
            chatDetailsStore.roomState = chatDetailsStore.roomState.fromIRCMessage(parsedIRCMessage);
            continue;
          case Command.userState:
            _userState = _userState.fromIRCMessage(parsedIRCMessage);
            if (toSend != null) {
              _messages.add(toSend!);
              toSend = null;
            }
            break;
          case Command.globalUserState:
            final setIds = parsedIRCMessage.tags['emote-sets']?.split(',');
            if (setIds != null) {
              assetsStore.userEmotesFuture(
                emoteSets: setIds,
                headers: auth.headersTwitch,
                onError: (error) {
                  debugPrint(error.toString());
                  return <Emote>[];
                },
              );
            }
            continue;
          case Command.none:
            debugPrint('Unknown command: ${parsedIRCMessage.command}');
            continue;
        }

        if (_autoScroll) {
          if (_messages.length >= _messageLimit) _messages.removeAt(0);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });
        }

        // Remove messages when an upper limit is reached.
        // This will prevent an infinite amount of messages when autoscroll is off.
        if (_messages.length >= _messageUpperLimit) _messages.removeRange(0, 500);

        // Hard upper-limit of 5000 messages to prevent infinite messages being added when scrolling.
      } else if (message == 'PING :tmi.twitch.tv') {
        _channel?.sink.add('PONG :tmi.twitch.tv');
        return;
      } else if (message.contains('Welcome, GLHF!')) {
        _messages
            .add(IRCMessage.createNotice(message: "Connected to $displayName${regexEnglish.hasMatch(displayName) ? '' : ' ($channelName)'}'s chat!"));

        // Fetch the assets used in chat including badges and emotes.
        assetsStore.assetsFuture(
          channelName: channelName,
          channelId: channelId,
          headers: auth.headersTwitch,
          onEmoteError: (error) {
            debugPrint(error.toString());
            return <Emote>[];
          },
          onBadgeError: (error) {
            debugPrint(error.toString());
            return <Badge>[];
          },
        );
        // Reset exponential backoff if successfully connected.
        _retries = 0;
        _backoffTime = 0;
      }
    }
  }

  /// Re-enables [_autoScroll] and jumps to the latest message.
  @action
  void resumeScroll() {
    if (_messages.length >= _messageLimit) _messages.removeRange(0, _messages.length - _messageLimit);

    _autoScroll = true;

    // Jump to the latest message (bottom of the list/chat).
    scrollController.jumpTo(scrollController.position.maxScrollExtent);

    // Schedule a postFrameCallback in the event a new message is added at the same time.
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollController.jumpTo(scrollController.position.maxScrollExtent));
  }

  @action
  void connectToChat() {
    _channel?.sink.close(1001);
    _channel = WebSocketChannel.connect(Uri.parse('wss://irc-ws.chat.twitch.tv:443'));

    // Listen for new messages and forward them to the handler.
    _channel?.stream.listen(
      (data) => _handleIRCData(data.toString()),
      onError: (error) => debugPrint('Chat error: ${error.toString()}'),
      onDone: () async {
        if (_channel == null) return;

        if (_backoffTime > 0) {
          // Add notice that chat was disconnected and then wait the backoff time before reconnecting.
          final notice = 'Disconnected from chat, waiting $_backoffTime ${_backoffTime == 1 ? 'second' : 'seconds'} before reconnecting...';
          _messages.add(IRCMessage.createNotice(message: notice));
        }

        await Future.delayed(Duration(seconds: _backoffTime));

        // Increase the backoff time for the next retry.
        _backoffTime == 0 ? _backoffTime++ : _backoffTime *= 2;

        // Increment the retry count and attempt the reconnect.
        _retries++;
        _messages.add(IRCMessage.createNotice(message: 'Reconnecting to chat (attempt $_retries)...'));
        connectToChat();
      },
    );

    // The list of messages sent to the IRC WebSocket channel to connect and join.
    final commands = [
      // Request the tags and commands capabilities.
      // This will display tags containing metadata along with each IRC message.
      'CAP REQ :twitch.tv/tags twitch.tv/commands',

      // The OAuth token in order to connect, default or user token.
      'PASS oauth:${auth.token}',

      // The nickname for the connecting user. 'justinfan888' is the Twitch default if not logged in.
      'NICK ${auth.isLoggedIn ? auth.user.details!.login : 'justinfan888'}',

      // Join the desired channel's room.
      'JOIN #$channelName',
    ];

    // Send each command in order.
    for (final command in commands) {
      _channel?.sink.add(command);
    }
  }

  /// Sends the given string message by the logged-in user and adds it to [_messages].
  @action
  void sendMessage(String message) {
    // Do not send if the message is blank/empty.
    if (message.isEmpty) return;

    if (_channel == null || _channel?.closeCode != null) {
      _messages.add(IRCMessage.createNotice(message: 'Failed to send message: disconnected from chat.'));
    } else {
      // Send the message to the IRC chat room.
      _channel?.sink.add('PRIVMSG #$channelName :$message');

      // Obtain the logged-in user's appearance in chat with USERSTATE and create the full message to render.
      var userStateString = _userState.raw;
      if (userStateString != null) {
        if (message.length > 3 && message.substring(0, 3) == '/me') {
          userStateString += ' :\x01ACTION ${message.replaceRange(0, 3, '').trim()}\x01';
        } else {
          userStateString += ' :${message.trim()}';
        }

        final userChatMessage = IRCMessage.fromString(userStateString);
        userChatMessage.localEmotes?.addAll(assetsStore.userEmoteToObject);

        toSend = userChatMessage;
      }

      // Clear the previous input in the TextField.
      textController.clear();
    }

    // Scroll to the latest message after sending.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  /// Adds the given [emote] to the chat textfield.
  @action
  void addEmote(Emote emote, {bool autocompleteMode = false}) {
    if (textController.text.isEmpty || textController.text.endsWith(' ')) {
      textController.text += '${emote.name} ';
    } else if (autocompleteMode && _showAutocomplete && textController.text.endsWith('')) {
      final split = textController.text.split(' ')
        ..removeLast()
        ..add('${emote.name} ');

      textController.text = split.join(' ');
    } else {
      textController.text += ' ${emote.name} ';
    }

    assetsStore.recentEmotes
      ..removeWhere((recentEmote) => recentEmote.name == emote.name && recentEmote.type == emote.type)
      ..insert(0, emote);

    textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
  }

  /// Closes and disposes all the channels and controllers used by the store.
  void dispose() {
    _channel?.sink.close(1001);
    _channel = null;

    for (final reactionDisposer in reactions) {
      reactionDisposer();
    }

    textFieldFocusNode.dispose();
    textController.dispose();
    scrollController.dispose();
    assetsStore.dispose();
  }
}

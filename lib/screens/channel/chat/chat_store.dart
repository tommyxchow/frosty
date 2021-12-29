import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/models/irc_message.dart';
import 'package:frosty/screens/channel/chat/chat_assets_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:mobx/mobx.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

/// The store and view-model for chat-related activities.
class ChatStore = _ChatStoreBase with _$ChatStore;

abstract class _ChatStoreBase with Store {
  /// The provided auth store to determine login status, get the token, and use the headers for requests.
  final AuthStore auth;

  /// The provided setting store to account for any user-defined behaviors.
  final SettingsStore settings;

  /// The name of the channel to connect to.
  final String channelName;

  /// The Twitch IRC WebSocket channel.
  final _channel = WebSocketChannel.connect(Uri.parse('wss://irc-ws.chat.twitch.tv:443'));

  /// The scroll controller that controls auto-scroll and resume-scroll behavior.
  final scrollController = ScrollController();

  /// The text controller that handles the TextField inputs and sending of messages.
  final textController = TextEditingController();

  /// The chat details store responsible for the chat modes and users in chat.
  final chatDetailsStore = ChatDetailsStore();

  /// The assets store responsible for badges, emotes, and the emote menu.
  final assetsStore = ChatAssetsStore();

  /// Requested message to be sent by the user. Will only be sent on receival of a USERNOTICE command.
  IRCMessage? toSend;

  /// The list of chat messages to render and display.
  @readonly
  var _messages = ObservableList<IRCMessage>();

  /// If the chat should automatically scroll/jump to the latest message.
  @readonly
  var _autoScroll = true;

  /// The logged-in user's appearance in chat.
  @readonly
  var _userState = const USERSTATE();

  _ChatStoreBase({
    required this.auth,
    required this.settings,
    required this.channelName,
  }) {
    // Create a reaction where anytime the emote menu is shown or hidden,
    // scroll to the bottom of the list. This will prevent the emote menu
    // from covering the latest messages when summoned.
    final disposeEmoteMenuReaction = reaction((_) => assetsStore.showEmoteMenu, (_) {
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        if (scrollController.hasClients) scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    });

    _messages.add(IRCMessage.createNotice(message: 'Connecting to chat...'));

    // Listen for new messages and forward them to the handler.
    _channel.stream.listen(
      (data) => _handleIRCData(data.toString()),
      onError: (error) {
        debugPrint('Chat error: ${error.toString()}');
        _messages.add(IRCMessage.createNotice(message: 'Chat error - ${error.toString()}'));
      },
      onDone: () {
        debugPrint("Disconnected from $channelName's chat.");
        _messages.add(IRCMessage.createNotice(message: 'Failed to connect to chat, please try again.'));
        disposeEmoteMenuReaction();
      },
    );

    // Fetch the users in chat.
    chatDetailsStore.updateChatters(channelName);

    // Fetch the assets used in chat including badges and emotes.
    _messages.add(IRCMessage.createNotice(message: 'Fetching channel assets...'));

    assetsStore
        .getAssets(channelName: channelName, headers: auth.headersTwitch)
        .then((_) => _messages.add(IRCMessage.createNotice(message: 'Channel assets fetched!')))
        .onError((error, stackTrace) => _messages.add(IRCMessage.createNotice(message: 'Failed to fetch assets: ${error.toString()}')));

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
      _channel.sink.add(command);
    }

    _messages.add(IRCMessage.createNotice(message: "Connected to $channelName's chat."));

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
      if (message.startsWith('@')) {
        final parsedIRCMessage = IRCMessage.fromString(message);

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
            _messages.add(IRCMessage.createNotice(message: 'Fetching user emotes...'));
            assetsStore
                .getUserEmotes(emoteSets: setIds, headers: auth.headersTwitch)
                .then((_) => _messages.add(IRCMessage.createNotice(message: 'User emotes fetched!')))
                .onError((error, stackTrace) => _messages.add(IRCMessage.createNotice(message: 'Failed to fetch user emotes: ${error.toString()}')));
            continue;
          case Command.none:
            debugPrint('Unknown command: ${parsedIRCMessage.command}');
            continue;
        }

        if (_autoScroll) _deleteAndScrollToEnd();

        // Hard upper-limit of 10000 messages to prevent infinite messages being added when scrolling.
        if (_messages.length >= 10000) _messages.removeRange(0, 2000);
      } else if (message == 'PING :tmi.twitch.tv') {
        _channel.sink.add('PONG :tmi.twitch.tv');
        return;
      }
    }
  }

  /// If [_autoScroll] is enabled, removes messages if [_messages] is too large and scrolls to the latest message.
  @action
  void _deleteAndScrollToEnd() {
    // If we reach 1000 messages, remove the oldest 200.
    if (_messages.length >= 1000) _messages.removeRange(0, 200);

    // Jump to the latest message (bottom of the list/chat).
    if (scrollController.hasClients) scrollController.jumpTo(scrollController.position.maxScrollExtent);

    // After the end of the frame, scroll to the bottom of the chat.
    // This is a postFrameCallback because the chat should scroll after the widget is built and rendered.
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (scrollController.hasClients) scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  /// Re-enables [_autoScroll] and jumps to the latest message.
  @action
  void resumeScroll() {
    _autoScroll = true;

    // Jump to the latest message (bottom of the list/chat).
    scrollController.jumpTo(scrollController.position.maxScrollExtent);

    // Schedule a postFrameCallback in the event a new message is added at the same time.
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  /// Sends the given string message by the logged-in user and adds it to [_messages].
  void sendMessage(String message) {
    // Do not send if the message is blank/empty.
    if (message.isEmpty) {
      return;
    }

    // Send the message to the IRC chat room.
    _channel.sink.add('PRIVMSG #$channelName :$message');

    // Obtain the logged-in user's appearance in chat with USERSTATE and create the full message to render.
    final userStateString = _userState.raw;
    if (userStateString != null) {
      // TODO: Add support for /me when sending messages.
      // if (message.substring(0, 3) == '/me') {
      //   message = '\x01' + 'ACTION' + message + '\x01';
      // }

      final userChatMessage = IRCMessage.fromString(userStateString);
      userChatMessage.localEmotes.addAll(assetsStore.userEmoteToObject);
      userChatMessage.message = message.trim();
      toSend = userChatMessage;
    }

    // Clear the previous input in the TextField.
    textController.clear();
  }

  /// Pauses or resumes the chat subscription depending on the provided state.
  void handleAppStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Closes and disposes all the channels and controllers used by the store.
  void dispose() {
    _channel.sink.close();
    textController.dispose();
    scrollController.dispose();
  }
}

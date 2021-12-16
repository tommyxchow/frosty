import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frosty/api/bttv_api.dart';
import 'package:frosty/api/ffz_api.dart';
import 'package:frosty/api/seventv_api.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/irc_message.dart';
import 'package:mobx/mobx.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

/// The store and view-model for chat-related activities.
class ChatStore = _ChatStoreBase with _$ChatStore;

abstract class _ChatStoreBase with Store {
  /// The Twitch IRC WebSocket channel.
  final _channel = WebSocketChannel.connect(Uri.parse('wss://irc-ws.chat.twitch.tv:443'));

  /// The map of emote words to their image or GIF URL.
  final _emoteToObject = <String, Emote>{};
  Map<String, Emote> get emoteToObject => _emoteToObject;

  /// The map of badges ids to their object representation.
  final _badgesToObject = <String, BadgeInfoTwitch>{};
  Map<String, BadgeInfoTwitch> get badgesToObject => _badgesToObject;

  /// The scroll controller that controls auto-scroll and resume-scroll behavior.
  final scrollController = ScrollController();

  /// The text controller that handles the TextField inputs and sending of messages.
  final textController = TextEditingController();

  /// The name of the channel to connect to.
  final String channelName;

  /// The provided auth store to determine login status, get the token, and use the headers for requests.
  final AuthStore auth;

  /// The provided setting store to account for any user-defined behaviors.
  final SettingsStore settings;

  /// Requested message to be sent by the user. Will only be sent on receival of a USERNOTICE command.
  IRCMessage? toSend;

  /// The current index of the emote menu stack.
  @observable
  var emoteMenuIndex = 0;

  /// Whether or not the emote menu is visible.
  @observable
  var showEmoteMenu = false;

  /// The list of chat messages to render and display.
  @readonly
  var _messages = ObservableList<IRCMessage>();

  /// If the chat should automatically scroll/jump to the latest message.
  @readonly
  var _autoScroll = true;

  /// The logged-in user's appearance in chat.
  @readonly
  var _userState = const USERSTATE();

  /// The rules and modes being used in the chat.
  @readonly
  var _roomState = const ROOMSTATE();

  _ChatStoreBase({
    required this.auth,
    required this.settings,
    required this.channelName,
  }) {
    // Create a reaction where anytime the emote menu is shown or hidden,
    // scroll to the bottom of the list. This will prevent the emote menu
    // from covering the latest messages when summoned.
    final disposeEmoteMenuReaction = reaction((_) => showEmoteMenu, (_) {
      debugPrint('reaction');
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    });

    _messages.add(IRCMessage.createNotice(message: 'Connecting to chat...'));

    getAssets();

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

    // The list of messages sent to the IRC WebSocket channel to connect and join.
    final commands = [
      // Request the tags and commands capabilities.
      // This will display tags containing metadata along with each IRC message.
      'CAP REQ :twitch.tv/tags twitch.tv/commands',

      // The OAuth token in order to connect, default or user token.
      'PASS oauth:${auth.token}',

      // The nickname for the connecting user. 'justinfan888' is the Twitch default if not logged in.
      'NICK ${auth.isLoggedIn ? auth.user!.login : 'justinfan888'}',

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
            channelName != auth.user?.login &&
            auth.blockedUsers.where((blockedUser) => blockedUser.userLogin == parsedIRCMessage.user).isNotEmpty) continue;

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
            _roomState = _roomState.fromIRC(parsedIRCMessage);
            continue;
          case Command.userState:
            _userState = _userState.fromIRC(parsedIRCMessage);
            if (toSend != null) {
              _messages.add(toSend!);
              toSend = null;
            }
            break;
          case Command.globalUserState:
            // Updates the current global user state data (it includes user-id),
            // Don't really see a use for it when USERSTATE exists, so leaving it unimplemented for now.
            continue;
          case Command.none:
            debugPrint('Unknown command: ${parsedIRCMessage.command}');
            continue;
        }

        _deleteAndScrollToEnd();
      } else if (message == 'PING :tmi.twitch.tv') {
        _channel.sink.add('PONG :tmi.twitch.tv');
        return;
      }
    }
  }

  /// If [_autoScroll] is enabled, removes messages if [_messages] is too large and scrolls to the latest message.
  @action
  void _deleteAndScrollToEnd() {
    if (_autoScroll) {
      // If there are more messages than the limit, remove around 10% of them from the oldest.
      if (_messages.length > settings.messageLimit && settings.messageLimit != 1000) {
        _messages.removeRange(0, (settings.messageLimit / 5).ceil());
      }

      // After the end of the frame, scroll to the bottom of the chat.
      // This is a postFrameCallback because the chat should scroll after the widget is built and rendered.
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    }
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
      final userChatMessage = IRCMessage.fromString(userStateString);
      userChatMessage.message = message;
      toSend = userChatMessage;
    }

    // Clear the previous input in the TextField.
    textController.clear();
  }

  /// Fetches global and channel assets (badges and emotes) and stores them in [_emoteToUrl]
  Future<void> getAssets() async {
    _messages.add(IRCMessage.createNotice(message: 'Fetching channel assets...'));

    // Fetch the desired channel/user's information.
    final channelInfo = await Twitch.getUser(userLogin: channelName, headers: auth.headersTwitch);

    if (channelInfo != null) {
      // Fetch the global and channel's assets (emotes & badges).
      // Async awaits are placed in a list so they are performed in parallel.
      final assets = [
        ...await FFZ.getEmotesGlobal(),
        ...await FFZ.getEmotesChannel(id: channelInfo.id),
        ...await BTTV.getEmotesGlobal(),
        ...await BTTV.getEmotesChannel(id: channelInfo.id),
        ...await Twitch.getEmotesGlobal(headers: auth.headersTwitch),
        ...await Twitch.getEmotesChannel(id: channelInfo.id, headers: auth.headersTwitch),
        ...await SevenTV.getEmotesGlobal(),
        ...await SevenTV.getEmotesChannel(user: channelInfo.login)
      ];

      assets.sort((a, b) => a.id.compareTo(b.id));

      for (final emote in assets) {
        _emoteToObject[emote.name] = emote;
      }

      final badges = [
        await Twitch.getBadgesGlobal(),
        await Twitch.getBadgesChannel(id: channelInfo.id),
      ];

      for (final map in badges) {
        if (map != null) {
          _badgesToObject.addAll(map);
        }
      }

      _messages.add(IRCMessage.createNotice(message: 'Channel assets fetched!'));
    }
  }

  /// Returns the readable text for the given emote type.
  String emoteMenuTitle(EmoteType type) {
    switch (type) {
      case EmoteType.twitchGlobal:
        return 'Twitch Global';
      case EmoteType.twitchChannel:
        return 'Twitch Channel';
      case EmoteType.ffzGlobal:
        return 'FFZ Global';
      case EmoteType.ffzChannel:
        return 'FFZ Channel';
      case EmoteType.bttvGlobal:
        return 'BTTV Global';
      case EmoteType.bttvChannel:
        return 'BTTV Channel';
      case EmoteType.bttvShared:
        return 'BTTV Shared';
      case EmoteType.sevenTvGlobal:
        return '7TV Global';
      case EmoteType.sevenTvChannel:
        return '7TV Channel';
    }
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

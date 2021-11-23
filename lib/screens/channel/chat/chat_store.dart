import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/api/bttv_api.dart';
import 'package:frosty/api/ffz_api.dart';
import 'package:frosty/api/irc_api.dart';
import 'package:frosty/api/seventv_api.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/models/irc.dart';
import 'package:mobx/mobx.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

/// The store and view-model for chat-related activities.
class ChatStore = _ChatStoreBase with _$ChatStore;

abstract class _ChatStoreBase with Store {
  /// The Twitch IRC WebSocket channel.
  final _channel = WebSocketChannel.connect(Uri.parse('wss://irc-ws.chat.twitch.tv:443'));

  /// The map of badges and emote words to their image or GIF URL.
  final _assetToUrl = <String, String>{};

  /// The list of chat messages to render and display.
  final messages = ObservableList<IRCMessage>();

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

  /// The logged-in user's appearance in chat.
  String? _userState;

  /// Requested message to be sent by the user. Will only be sent on receival of a USERNOTICE command.
  IRCMessage? toSend;

  /// If the chat should automatically scroll/jump to the latest message.
  @readonly
  var _autoScroll = true;

  /// The rules and modes being used in the chat.
  @readonly
  var _roomState = const ROOMSTATE();

  _ChatStoreBase({
    required this.auth,
    required this.settings,
    required this.channelName,
  }) {
    // Listen for new messages and forward them to the handler.
    _channel.stream.listen(
      (data) => _handleIRCData(data.toString()),
      onDone: () => debugPrint("Disconnected from $channelName's chat."),
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

    // Tell the scrollController to determine when auto-scroll should be enabled or disabled.
    scrollController.addListener(() {
      // If the user scrolls up, auto-scroll will stop, allowing them to freely scroll back to previous messages.
      // Else if the user scrolls back to the bottom edge (latest message), auto-scroll will resume.
      if (!scrollController.position.atEdge && scrollController.position.pixels < scrollController.position.maxScrollExtent) {
        _autoScroll = false;
      } else if (scrollController.position.atEdge && scrollController.position.pixels != scrollController.position.minScrollExtent) {
        _autoScroll = true;
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

        switch (parsedIRCMessage.command) {
          case Command.privateMessage:
            messages.add(parsedIRCMessage);
            break;
          case Command.clearChat:
            IRC.clearChat(messages: messages, ircMessage: parsedIRCMessage);
            break;
          case Command.clearMessage:
            IRC.clearMessage(messages: messages, ircMessage: parsedIRCMessage);
            break;
          case Command.notice:
          case Command.userNotice:
            messages.add(parsedIRCMessage);
            break;
          case Command.roomState:
            _roomState = _roomState.copyWith(parsedIRCMessage);
            continue;
          case Command.userState:
            _userState = message;
            if (toSend != null) {
              messages.add(toSend!);
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

  /// Sends the given string message by the logged-in user and adds it to [messages].
  @action
  void sendMessage(String message) {
    // Do not send if the message is blank/empty.
    if (message.isEmpty) {
      return;
    }

    // Send the message to the IRC chat room.
    _channel.sink.add('PRIVMSG #$channelName :$message');

    // Obtain the logged-in user's appearance in chat with USERSTATE and create the full message to render.
    if (_userState != null) {
      final userChatMessage = IRCMessage.fromString(_userState!);
      userChatMessage.message = message;
      toSend = userChatMessage;
    }

    // Clear the previous input in the TextField.
    textController.clear();
  }

  /// If [_autoScroll] is enabled, removes messages if [messages] is too large and scrolls to the latest message.
  @action
  void _deleteAndScrollToEnd() {
    if (_autoScroll) {
      // If there are more messages than the limit, remove around 10% of them from the oldest.
      if (messages.length > settings.messageLimit && settings.messageLimit != 1000) {
        messages.removeRange(0, (messages.length - settings.messageLimit * 0.1).ceil());
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

  /// Fetches global and channel assets (badges and emotes) and stores them in [_assetToUrl]
  Future<void> getAssets() async {
    // Fetch the desired channel/user's information.
    final channelInfo = await Twitch.getUser(userLogin: channelName, headers: auth.headersTwitch);

    if (channelInfo != null) {
      // Fetch the global and channel's assets (emotes & badges).
      // Async awaits are placed in a list so they are performed in parallel.
      final assets = [
        await FFZ.getEmotesGlobal(),
        await FFZ.getEmotesChannel(id: channelInfo.id),
        await BTTV.getEmotesGlobal(),
        await BTTV.getEmotesChannel(id: channelInfo.id),
        await Twitch.getEmotesGlobal(headers: auth.headersTwitch),
        await Twitch.getEmotesChannel(id: channelInfo.id, headers: auth.headersTwitch),
        await Twitch.getBadgesGlobal(headers: auth.headersTwitch),
        await Twitch.getBadgesChannel(id: channelInfo.id, headers: auth.headersTwitch),
        await SevenTV.getEmotesGlobal(),
        await SevenTV.getEmotesChannel(user: channelInfo.login)
      ];

      // Add all the assets to the global word-to-asset map.
      // 'Global' meaning these assets can be used by any message when rendering.
      for (final map in assets) {
        if (map != null) {
          _assetToUrl.addAll(map);
        }
      }
    }
  }

  // TODO: Split render functions and use switch statment.
  /// Returns a chat message widget for the given [IRCMessage].
  Widget renderChatMessage(IRCMessage ircMessage, BuildContext context) {
    if (ircMessage.command == Command.clearChat || ircMessage.command == Command.clearMessage) {
      final span = IRC.generateSpan(ircMessage: ircMessage, assetToUrl: _assetToUrl);

      // Render timeouts and bans
      final banDuration = ircMessage.tags['ban-duration'];
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Opacity(
          opacity: 0.50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: span,
                ),
              ),
              const SizedBox(height: 5),
              banDuration == null
                  ? (ircMessage.command == Command.clearMessage)
                      ? const Text('Message deleted.')
                      : const Text('Permanently Banned.')
                  : Text(
                      'Timed out for $banDuration second(s).',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ],
          ),
        ),
      );
    } else if (ircMessage.command == Command.notice) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text.rich(
          TextSpan(
            text: ircMessage.message,
          ),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.5),
          ),
        ),
      );
    } else if (ircMessage.command == Command.userNotice) {
      final span = IRC.generateSpan(ircMessage: ircMessage, assetToUrl: _assetToUrl);

      // Render sub alerts
      return Container(
        color: Colors.purple.withOpacity(0.3),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ircMessage.tags['system-msg']!),
            const SizedBox(height: 5),
            if (ircMessage.message != null)
              Text.rich(
                TextSpan(
                  children: span,
                ),
              ),
          ],
        ),
      );
    } else {
      final span = IRC.generateSpan(ircMessage: ircMessage, assetToUrl: _assetToUrl);

      // Render normal chat message (PRIVMSG).
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Text.rich(
          TextSpan(
            children: span,
          ),
        ),
      );
    }
  }

  /// Closes and disposes all the channels and controllers used by the store.
  void dispose() {
    _channel.sink.close();
    textController.dispose();
    scrollController.dispose();
  }
}

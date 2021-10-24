import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/api/bttv_api.dart';
import 'package:frosty/api/ffz_api.dart';
import 'package:frosty/api/irc_api.dart';
import 'package:frosty/api/seventv_api.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/widgets/chat_message.dart';
import 'package:mobx/mobx.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

class ChatStore = _ChatStoreBase with _$ChatStore;

abstract class _ChatStoreBase with Store {
  @readonly
  var _autoScroll = true;

  @readonly
  var _roomState = ROOMSTATE();

  String? _userState;

  // String? _globalUserState;

  final messages = ObservableList<IRCMessage>();

  final _assetToUrl = <String, String>{};

  final _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  final _textController = TextEditingController();
  TextEditingController get textController => _textController;

  final _channel = WebSocketChannel.connect(Uri.parse('wss://irc-ws.chat.twitch.tv:443'));
  WebSocketChannel get channel => _channel;

  final String channelName;

  final AuthStore auth;

  _ChatStoreBase({required this.auth, required this.channelName}) {
    channel.stream.listen(
      (data) => _handleWebsocketData(data.toString()),
      onDone: () => debugPrint("DONE"),
    );

    final commands = [
      'CAP REQ :twitch.tv/tags twitch.tv/commands',
      'PASS oauth:${auth.token}',
      'NICK ${auth.isLoggedIn ? auth.user!.login : 'justinfan888'}',
      'JOIN #$channelName',
    ];

    for (final command in commands) {
      channel.sink.add(command);
    }

    _scrollController.addListener(() {
      if (!_scrollController.position.atEdge && _scrollController.position.pixels < _scrollController.position.maxScrollExtent) {
        _autoScroll = false;
      } else if (_scrollController.position.atEdge && _scrollController.position.pixels != _scrollController.position.minScrollExtent) {
        _autoScroll = true;
      }
    });
  }

  Future<void> getAssets() async {
    final channelInfo = await Twitch.getUser(userLogin: channelName, headers: auth.headersTwitch);

    if (channelInfo != null) {
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

      for (final map in assets) {
        if (map != null) {
          _assetToUrl.addAll(map);
        }
      }
    }
  }

  @action
  void _handleWebsocketData(String data) {
    for (final message in data.substring(0, data.length - 2).split('\r\n')) {
      // debugPrint(message);
      if (message.startsWith('@')) {
        final parsedIRCMessage = IRCMessage.fromString(message);

        switch (parsedIRCMessage.command) {
          case Command.privateMessage:
            messages.add(parsedIRCMessage);
            _scrollToEnd();
            break;
          case Command.clearChat:
            IRC.clearChat(messages: messages, ircMessage: parsedIRCMessage);
            _scrollToEnd();
            break;
          case Command.clearMessage:
            IRC.clearMessage(messages: messages, ircMessage: parsedIRCMessage);
            _scrollToEnd();
            break;
          case Command.userNotice:
            messages.add(parsedIRCMessage);
            _scrollToEnd();
            break;
          case Command.roomState:
            _roomState = _roomState.copyWith(parsedIRCMessage);
            break;
          case Command.userState:
            // Updates the current user-state data
            _userState = message;
            break;
          case Command.globalUserState:
            // Updates the current global user state data (it includes user-id),
            // Don't really see a use for it when USERSTATE exists, so leaving it unimplemented for now.
            // _globalUserState = message;
            break;
          default:
            debugPrint('Unknown command: ${parsedIRCMessage.command}');
        }
      } else if (message == 'PING :tmi.twitch.tv') {
        channel.sink.add('PONG :tmi.twitch.tv');
        return;
      }
    }
  }

  @action
  void _scrollToEnd() {
    if (_autoScroll) {
      if (messages.length > 200) {
        messages.removeRange(0, messages.length - 180);
      }

      SchedulerBinding.instance?.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  Widget renderChatMessage(IRCMessage ircMessage) {
    final span = IRC.generateSpan(ircMessage: ircMessage, assetToUrl: _assetToUrl);

    if (ircMessage.command == Command.clearChat || ircMessage.command == Command.clearMessage) {
      final banDuration = ircMessage.tags['ban-duration'];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Opacity(
          opacity: 0.50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChatMessage(
                key: Key(ircMessage.tags['id']!),
                children: span,
              ),
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
    } else if (ircMessage.command == Command.userNotice) {
      return Container(
        color: Colors.purple.withOpacity(0.25),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ircMessage.tags['system-msg']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (ircMessage.message != null)
              ChatMessage(
                key: Key(ircMessage.tags['id']!),
                children: span,
              ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: ChatMessage(
          key: ircMessage.tags['id'] == null ? null : Key(ircMessage.tags['id']!),
          children: span,
        ),
      );
    }
  }

  void sendMessage(String message) {
    if (message.isEmpty) {
      return;
    }

    _channel.sink.add('PRIVMSG #$channelName :$message');

    final userChatMessage = IRCMessage.fromString(_userState!);
    userChatMessage.message = message;
    messages.add(userChatMessage);

    _textController.clear();
  }

  @action
  void resumeScroll() {
    _autoScroll = true;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void dispose() {
    _channel.sink.close();
    _textController.dispose();
    _scrollController.dispose();
  }
}

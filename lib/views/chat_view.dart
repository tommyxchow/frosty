import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/utility/request.dart';
import 'package:frosty/widgets/chat_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chat extends StatefulWidget {
  final Channel channelInfo;

  const Chat({Key? key, required this.channelInfo}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _channel = WebSocketChannel.connect(Uri.parse(twitchIrcUrl));
  final _messages = <Widget>[];
  final _assetToUrl = <String, String>{};
  final _emoteIdToWord = <String, String>{};
  final _scrollController = ScrollController();

  final _token = const String.fromEnvironment('TEST_TOKEN');

  Future<void> getEmotes() async {
    final response = [
      await Request.getEmotesBTTVGlobal(),
      await Request.getEmotesBTTVChannel(id: widget.channelInfo.userId),
      await Request.getEmotesFFZGlobal(),
      await Request.getEmotesFFZChannel(id: widget.channelInfo.userId),
      await Request.getEmotesTwitchGlobal(token: _token),
      await Request.getEmotesTwitchChannel(token: _token, id: widget.channelInfo.userId),
      await Request.getBadgesTwitchGlobal(token: _token),
      await Request.getBadgesTwitchChannel(token: _token, id: widget.channelInfo.userId),
    ];

    for (final map in response) {
      _assetToUrl.addAll(map);
    }
  }

  @override
  void initState() {
    super.initState();
    final commands = [
      'CAP LS 302',
      'PASS oauth:$_token',
      'NICK justinfan888',
      'JOIN #${widget.channelInfo.userLogin}',
      'CAP REQ :twitch.tv/commands',
      'CAP REQ :twitch.tv/tags',
      'CAP END',
    ];

    for (final command in commands) {
      _channel.sink.add(command);
    }
  }

  List<InlineSpan> parseIrcMessage(String whole) {
    var mappedTags = <String, String>{};

    final tagAndIrcMessageDivider = whole.indexOf(' ');
    final tags = whole.substring(1, tagAndIrcMessageDivider).replaceAll('\\s', ' ');
    final ircMessage = whole.substring(tagAndIrcMessageDivider + 2);

    for (final tag in tags.split(';')) {
      if (!tag.endsWith('=')) {
        final tagSplit = tag.split('=');
        mappedTags[tagSplit[0]] = tagSplit[1];
      }
    }
    final ircAndMessageDivider = ircMessage.indexOf(':');

    final ircInfo = ircMessage.substring(0, ircAndMessageDivider);
    final message = ircMessage.substring(ircAndMessageDivider + 1);

    final ircInfoSplit = ircInfo.split(' ');
    final command = ircInfoSplit[1];

    switch (command) {
      case 'CLEARCHAT':
        break;
      case 'CLEARMSG':
        break;
      case 'GLOBALUSERSTATE':
        break;
      case 'PRIVMSG':
        return privateMessage(tags: mappedTags, chatMessage: message);
      case 'ROOMSTATE':
        break;
      case 'USERNOTICE':
        break;
      case 'USERSTATE':
        break;
    }
    return [];
  }

  List<InlineSpan> privateMessage({required Map<String, String> tags, required String chatMessage}) {
    var result = <InlineSpan>[];

    final emoteTags = tags['emotes'];
    if (emoteTags != null) {
      final emotes = emoteTags.split('/');

      for (final emoteIdAndPosition in emotes) {
        final indexBetweenIdAndPositions = emoteIdAndPosition.indexOf(':');
        final emoteId = emoteIdAndPosition.substring(0, indexBetweenIdAndPositions);

        if (_emoteIdToWord[emoteId] != null) {
          continue;
        }

        final String range;
        if (emoteIdAndPosition.contains(',')) {
          range = emoteIdAndPosition.substring(indexBetweenIdAndPositions + 1, emoteIdAndPosition.indexOf(','));
        } else {
          range = emoteIdAndPosition.substring(indexBetweenIdAndPositions + 1);
        }

        final indexSplit = range.split('-');
        final startIndex = int.parse(indexSplit[0]);
        final endIndex = int.parse(indexSplit[1]);

        final emoteWord = chatMessage.substring(startIndex, endIndex + 1);

        _emoteIdToWord[emoteId] = emoteWord;
        _assetToUrl[emoteWord] = 'https://static-cdn.jtvnw.net/emoticons/v2/$emoteId/default/dark/3.0';
      }
    }

    final words = chatMessage.split(' ');
    final badges = tags['badges'];
    if (badges != null) {
      for (final badge in badges.split(',')) {
        final badgeUrl = _assetToUrl[badge];
        if (badgeUrl != null) {
          result.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Image.network(
                badgeUrl,
                height: 20,
              ),
            ),
          );
          result.add(const TextSpan(text: ' '));
        }
      }
    }

    result.add(
      TextSpan(
        text: tags['display-name']! + ':',
      ),
    );

    for (final word in words) {
      final emoteUrl = _assetToUrl[word];
      if (emoteUrl != null) {
        result.add(const TextSpan(text: ' '));
        result.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Image.network(
              emoteUrl,
              height: 25,
            ),
          ),
        );
      } else {
        result.add(const TextSpan(text: ' '));
        result.add(TextSpan(text: word));
      }
    }
    return result;
  }

  // Here, we have a FutureBuilder that will wait for the emotes to be fetched.
  // Once the emotes are acquired, the chat builder will start.

  // TODO: Maybe StreamBuilder first, then FutureBuilder?
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getEmotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                for (final message in snapshot.data.toString().split('\r\n')) {
                  print(message);
                  if (message.startsWith('@')) {
                    _messages.add(const SizedBox(height: 10));
                    _messages.add(ChatMessage(
                      children: parseIrcMessage(message),
                    ));
                  }
                  SchedulerBinding.instance?.addPostFrameCallback((_) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  });
                }
                return ListView.builder(
                  itemCount: _messages.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return _messages[index];
                  },
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}

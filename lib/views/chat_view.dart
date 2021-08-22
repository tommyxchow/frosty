import 'package:flutter/material.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/utility/request.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chat extends StatefulWidget {
  final Channel channelInfo;

  const Chat({Key? key, required this.channelInfo}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _channel = WebSocketChannel.connect(Uri.parse(twitchIrcUrl));
  final _messages = <String>[];
  final _emoteToURL = <String, String>{};

  final _token = const String.fromEnvironment('TEST_TOKEN');

  Future<void> getEmotes() async {
    final response = [
      await Request.getEmotesBTTVGlobal(),
      await Request.getEmotesBTTVChannel(id: widget.channelInfo.userId),
      await Request.getEmotesFFZGlobal(),
      await Request.getEmotesFFZChannel(id: widget.channelInfo.userId),
      await Request.getEmotesTwitchGlobal(token: _token),
      await Request.getEmotesTwitchChannel(token: _token, id: widget.channelInfo.userId)
    ];

    for (final map in response) {
      _emoteToURL.addAll(map);
    }
  }

  @override
  void initState() {
    super.initState();
    _channel.sink.add('NICK justinfan888');
    _channel.sink.add('JOIN #${widget.channelInfo.userLogin}');
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
                _messages.add('${snapshot.data}');
                if (_messages.length > 20) {
                  _messages.removeRange(0, 1);
                }
                return _messagesBuilder(context);
              },
            );
          }
          return Text('Loading chat...');
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Widget _messagesBuilder(BuildContext context) {
    return ListView(
      children: _messages.map((message) => _singleMessage(context, message.substring(0, message.length - 1))).toList(),
    );
  }

  Widget _singleMessage(BuildContext context, String message) {
    var result = <Widget>[];
    if (!message.contains(':')) {
      return Text('Test');
    }
    final split = message.substring(message.indexOf(':', 1) + 1, message.length - 1).split(' ');
    for (final word in split) {
      if (_emoteToURL[word] != null) {
        result.add(
          Image.network(
            _emoteToURL[word]!,
            height: 30,
          ),
        );
      } else {
        result.add(Text(' ' + word));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: result,
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/emotes.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _channel = WebSocketChannel.connect(Uri.parse(twitchIrc));
  final _messages = <String>[];
  final _emoteToURL = <String, String>{};

  final _id = '207813352';
  final _channelName = 'hasanabi';
  final _token = const String.fromEnvironment('TEST_TOKEN');

  Future<void> getEmotesBTTVGlobal() async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/emotes/global');
    final response = await http.get(url);
    final decoded = jsonDecode(response.body) as List;
    final List<EmoteBTTVGlobal> emotes = decoded.map((emote) => EmoteBTTVGlobal.fromJson(emote)).toList();

    for (var emote in emotes) {
      _emoteToURL[emote.code] = 'https://cdn.betterttv.net/emote/${emote.id}/3x';
    }
  }

  Future<void> getEmotesBTTVChannel({required String id}) async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/users/twitch/$id');
    final response = await http.get(url);
    final decoded = jsonDecode(response.body);
    final result = EmoteBTTVChannel.fromJson(decoded);

    for (final emote in result.channelEmotes) {
      _emoteToURL[emote.code] = 'https://cdn.betterttv.net/emote/${emote.id}/3x';
    }
    for (final emote in result.sharedEmotes) {
      _emoteToURL[emote.code] = 'https://cdn.betterttv.net/emote/${emote.id}/3x';
    }
  }

  Future<void> getEmotesFFZGlobal() async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/frankerfacez/emotes/global');
    final response = await http.get(url);
    final decoded = jsonDecode(response.body) as List;
    final List<EmoteFFZ> emotes = decoded.map((emote) => EmoteFFZ.fromJson(emote)).toList();

    for (var emote in emotes) {
      _emoteToURL[emote.code] = emote.images.url4x ?? emote.images.url1x;
    }
  }

  Future<void> getEmotesFFZChannel({required String id}) async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/frankerfacez/users/twitch/$id');
    final response = await http.get(url);
    final decoded = jsonDecode(response.body) as List;
    final List<EmoteFFZ> emotes = decoded.map((emote) => EmoteFFZ.fromJson(emote)).toList();

    for (var emote in emotes) {
      _emoteToURL[emote.code] = emote.images.url4x ?? emote.images.url1x;
    }
  }

  Future<void> getEmotesTwitchGlobal({required String token}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/emotes/global');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': const String.fromEnvironment('CLIENT_ID')};
    final response = await http.get(url, headers: headers);
    final decoded = jsonDecode(response.body)['data'] as List;
    final List<EmoteTwitch> emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

    for (var emote in emotes) {
      _emoteToURL[emote.name] = 'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0';
    }
  }

  Future<void> getEmotesTwitchChannel({required String token}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/emotes?broadcaster_id=$_id');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': const String.fromEnvironment('CLIENT_ID')};
    final response = await http.get(url, headers: headers);
    final decoded = jsonDecode(response.body)['data'] as List;
    final List<EmoteTwitch> emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

    for (var emote in emotes) {
      _emoteToURL[emote.name] = 'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0';
    }
  }

  Future<void> getEmotes() async {
    await getEmotesBTTVGlobal();
    await getEmotesBTTVChannel(id: _id);
    await getEmotesFFZGlobal();
    await getEmotesFFZChannel(id: _id);
    await getEmotesTwitchGlobal(token: _token);
    await getEmotesTwitchChannel(token: _token);
  }

  @override
  void initState() {
    super.initState();
    _channel.sink.add('NICK justinfan888');
    _channel.sink.add('JOIN #$_channelName');
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

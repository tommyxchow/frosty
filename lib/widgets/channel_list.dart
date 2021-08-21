import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/widgets/channel_card.dart';
import 'package:http/http.dart' as http;

class ChannelList extends StatefulWidget {
  const ChannelList({Key? key}) : super(key: key);

  @override
  _ChannelListState createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  var channels = <Channel>[];
  String? cursor;

  Future<void> getTopChannels({required String token}) async {
    final url;
    if (cursor != null) {
      url = Uri.parse('https://api.twitch.tv/helix/streams?first=10&after=$cursor');
    } else {
      url = Uri.parse('https://api.twitch.tv/helix/streams?first=10');
    }
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': const String.fromEnvironment('CLIENT_ID')};
    final response = await http.get(url, headers: headers);
    final decoded = jsonDecode(response.body);
    final data = decoded['data'] as List;
    cursor = decoded['pagination']['cursor'];

    channels += data.map((channel) => Channel.fromJson(channel)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getTopChannels(token: const String.fromEnvironment('TEST_TOKEN')),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              // TODO: Handle this case.
              break;
            case ConnectionState.waiting:
              // TODO: Handle this case.
              break;
            case ConnectionState.active:
              // TODO: Handle this case.
              break;
            case ConnectionState.done:
              return ListView.builder(
                itemBuilder: (context, index) {
                  print(index);
                  if (index >= channels.length / 2) {
                    print('fetching more channels...');
                    print(channels.length);
                    getTopChannels(token: const String.fromEnvironment('TEST_TOKEN'));
                  }
                  return ChannelCard(channelInfo: channels[index]);
                },
              );
          }
          return Text('loading');
        },
      ),
    );
  }
}

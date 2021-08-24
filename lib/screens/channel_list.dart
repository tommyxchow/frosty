import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/models/channel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/widgets/channel_card.dart';
import 'package:provider/provider.dart';

// FIXME: EXTREMELY fast scrolling will break.
class ChannelList extends StatefulWidget {
  const ChannelList({Key? key}) : super(key: key);

  @override
  _ChannelListState createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  final channels = <Channel>[];

  var _isLoading = false;

  String? currentCursor;

  /// Returns the top 10 streamers and a cursor for further requests.
  Future<void> getTopChannels({required String token, String? cursor}) async {
    _isLoading = true;
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

    final result = {'channels': data.map((channel) => Channel.fromJson(channel)).toList(), 'cursor': decoded['pagination']['cursor']};

    channels.addAll(result['channels']);
    currentCursor = result['cursor'];

    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Authentication>(
      builder: (context, auth, child) {
        return FutureBuilder(
          future: getTopChannels(token: auth.token!, cursor: currentCursor),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                padding: EdgeInsets.all(5.0),
                itemBuilder: (context, index) {
                  if (index >= channels.length / 2) {
                    if (!_isLoading) {
                      print('fetching more channels...');
                      getTopChannels(token: auth.token!, cursor: currentCursor);
                    }
                  }
                  return ChannelCard(channelInfo: channels[index]);
                },
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }
}

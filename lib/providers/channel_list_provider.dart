import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/models/channel.dart';
import 'package:http/http.dart' as http;

class ChannelListProvider extends ChangeNotifier {
  final channels = <Channel>[];
  String? cursor;

  /// Returns the top 10 streamers and a cursor for further requests.
  Future<void> getTopChannels({required String token, String? cursor}) async {
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
    cursor = result['cursor'];
  }
}

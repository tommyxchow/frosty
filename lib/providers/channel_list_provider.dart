import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:http/http.dart' as http;
import 'package:frosty/models/channel.dart';

class ChannelListProvider extends ChangeNotifier {
  var topChannels = <Channel>[];
  var followedChannels = <Channel>[];
  var isLoading = false;

  String? topChannelsCurrentCursor;
  String? followedChannelsCurrentCursor;

  final token = AuthenticationProvider.token;
  final String? id;

  ChannelListProvider({this.id}) {
    if (token != null) {
      updateTopChannels();
    }
    if (id != null) {
      updateFollowedChannels();
    }
  }

  String? currentCursor({required Category category}) {
    switch (category) {
      case Category.top:
        return topChannelsCurrentCursor;
      case Category.followed:
        return followedChannelsCurrentCursor;
    }
  }

  List<Channel> channels({required Category category}) {
    switch (category) {
      case Category.top:
        return topChannels;
      case Category.followed:
        return followedChannels;
    }
  }

  Future<void> update({required Category category}) async {
    switch (category) {
      case Category.top:
        await updateTopChannels();
        break;
      case Category.followed:
        await updateFollowedChannels();
        break;
    }
  }

  /// Returns the top 10 streamers and a cursor for further requests.
  Future<void> updateTopChannels() async {
    final url = Uri.parse('https://api.twitch.tv/helix/streams?first=10');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': clientId};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;

      final result = {'channels': data.map((channel) => Channel.fromJson(channel)).toList(), 'cursor': decoded['pagination']['cursor']};

      topChannels = result['channels'];
      topChannelsCurrentCursor = result['cursor'];
    } else {
      print('Failed to update top channels');
    }
    notifyListeners();
  }

  Future<void> getMoreChannels({required Category category}) async {
    isLoading = true;
    final url;

    switch (category) {
      case Category.top:
        url = Uri.parse('https://api.twitch.tv/helix/streams?first=10&after=$topChannelsCurrentCursor');
        break;
      case Category.followed:
        url = Uri.parse('https://api.twitch.tv/helix/streams/followed?user_id=$id&first=10&after=$followedChannelsCurrentCursor');
        break;
    }

    final headers = {'Authorization': 'Bearer $token', 'Client-Id': clientId};
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;

      final result = {'channels': data.map((channel) => Channel.fromJson(channel)).toList(), 'cursor': decoded['pagination']['cursor']};

      switch (category) {
        case Category.top:
          topChannels.addAll(result['channels']);
          topChannelsCurrentCursor = result['cursor'];
          break;
        case Category.followed:
          followedChannels.addAll(result['channels']);
          followedChannelsCurrentCursor = result['cursor'];
          print(followedChannelsCurrentCursor);
          break;
      }
    } else {
      print('Failed to get more channels');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateFollowedChannels() async {
    final url = Uri.parse('https://api.twitch.tv/helix/streams/followed?first=10&user_id=$id');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': clientId};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;

      final result = {'channels': data.map((channel) => Channel.fromJson(channel)).toList(), 'cursor': decoded['pagination']['cursor']};

      followedChannels = result['channels'];
      followedChannelsCurrentCursor = result['cursor'];
    } else {
      print('Failed to update followed channls');
    }
    notifyListeners();
  }
}

enum Category { top, followed }

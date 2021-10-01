import 'package:mobx/mobx.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:http/http.dart' as http;
import 'package:frosty/models/channel.dart';

part 'channel_list_store.g.dart';

class ChannelListStore = _ChannelListBase with _$ChannelListStore;

abstract class _ChannelListBase with Store {
  @observable
  ObservableList<Channel> topChannels = ObservableList<Channel>();

  @observable
  ObservableList<Channel> followedChannels = ObservableList<Channel>();

  @observable
  bool isLoading = false;

  @observable
  String? topChannelsCurrentCursor;

  @observable
  String? followedChannelsCurrentCursor;

  final token = AuthBase.token;
  final String? id;

  _ChannelListBase({this.id}) {
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

  ObservableList<Channel> channels({required Category category}) {
    switch (category) {
      case Category.top:
        return topChannels;
      case Category.followed:
        return followedChannels;
    }
  }

  @action
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
  @action
  Future<void> updateTopChannels() async {
    final url = Uri.parse('https://api.twitch.tv/helix/streams?first=10');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': clientId};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;

      final result = {'channels': data.map((channel) => Channel.fromJson(channel)).toList(), 'cursor': decoded['pagination']['cursor']};

      topChannels = ObservableList.of(result['channels']);
      topChannelsCurrentCursor = result['cursor'];
    } else {
      debugPrint('Failed to update top channels');
    }
    // notifyListeners();
  }

  @action
  Future<void> getMoreChannels({required Category category}) async {
    isLoading = true;
    Uri url;

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
          debugPrint(followedChannelsCurrentCursor);
          break;
      }
    } else {
      debugPrint('Failed to get more channels');
    }
    isLoading = false;
    // notifyListeners();
  }

  @action
  Future<void> updateFollowedChannels() async {
    final url = Uri.parse('https://api.twitch.tv/helix/streams/followed?first=10&user_id=$id');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': clientId};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;

      final result = {'channels': data.map((channel) => Channel.fromJson(channel)).toList(), 'cursor': decoded['pagination']['cursor']};

      followedChannels = ObservableList.of(result['channels']);
      followedChannelsCurrentCursor = result['cursor'];
    } else {
      debugPrint('Failed to update followed channels');
    }
    // notifyListeners();
  }
}

enum Category { top, followed }

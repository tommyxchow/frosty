import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_store.g.dart';

class SearchStore = _SearchStoreBase with _$SearchStore;

abstract class _SearchStoreBase with Store {
  final textController = TextEditingController();

  final AuthStore authStore;

  @readonly
  var _searchHistory = ObservableList<String>();

  @readonly
  var _searchResults = <ChannelQuery>[];

  _SearchStoreBase({required this.authStore}) {
    init();
  }

  @action
  Future<void> init() async {
    // Retrieve the instance that will allow us to retrieve local search history.
    final prefs = await SharedPreferences.getInstance();

    _searchHistory = prefs.getStringList('search_history')?.asObservable() ?? ObservableList<String>();

    autorun((_) {
      if (_searchHistory.length > 8) _searchHistory.removeLast();
      prefs.setStringList('search_history', _searchHistory);
    });
  }

  @action
  Future<void> handleQuery(String query) async {
    if (query.isEmpty) return;

    _searchHistory.remove(query);
    _searchHistory.insert(0, query);

    final results = await Twitch.searchChannels(query: query, headers: authStore.headersTwitch);
    results.sort((c1, c2) => c2.isLive ? 1 : -1);

    _searchResults = results;
  }

  Future<void> handleSearch(BuildContext context, String search) async {
    final user = await Twitch.getUser(userLogin: search, headers: authStore.headersTwitch);
    if (user != null) {
      final channelInfo = await Twitch.getChannel(userId: user.id, headers: context.read<AuthStore>().headersTwitch);
      if (channelInfo != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return VideoChat(
                title: channelInfo.title,
                userName: channelInfo.broadcasterName,
                userLogin: channelInfo.broadcasterLogin,
              );
            },
          ),
        );
      } else {
        const snackBar = SnackBar(content: Text('Failed to get channel info :('));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      const snackBar = SnackBar(content: Text('User does not exist :('));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    textController.clear();
  }

  void clearSearch() {
    textController.clear();
    _searchResults = <ChannelQuery>[];
  }

  void dispose() {
    textController.dispose();
  }
}

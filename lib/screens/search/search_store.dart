import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/channel.dart';
import 'package:mobx/mobx.dart';
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

  Future<Channel?> searchChannel(String channelName) async {
    try {
      final user = await Twitch.getUser(userLogin: channelName, headers: authStore.headersTwitch);
      return await Twitch.getChannel(userId: user!.id, headers: authStore.headersTwitch);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  void clearSearch() {
    textController.clear();
    _searchResults = <ChannelQuery>[];
  }

  void dispose() {
    textController.dispose();
  }
}

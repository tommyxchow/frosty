import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_store.g.dart';

class SearchStore = SearchStoreBase with _$SearchStore;

abstract class SearchStoreBase with Store {
  final AuthStore authStore;

  final TwitchApi twitchApi;

  final textEditingController = TextEditingController();

  final textFieldFocusNode = FocusNode();

  Timer? _debounceTimer;

  @readonly
  var _searchText = '';

  @readonly
  var _searchHistory = ObservableList<String>();

  @readonly
  var _isSearching = false;

  @readonly
  ObservableFuture<List<ChannelQuery>>? _channelFuture;

  @readonly
  ObservableFuture<CategoriesTwitch?>? _categoryFuture;

  SearchStoreBase({required this.authStore, required this.twitchApi}) {
    init();
  }

  @action
  Future<void> init() async {
    // Retrieve the instance that will allow us to retrieve local search history.
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the search history from local storage. If it doesn't exist, use an empty list.
    _searchHistory =
        prefs.getStringList('search_history')?.asObservable() ??
        ObservableList<String>();

    // Create a reaction that will limit the history to 8 entries and update it to local storage automatically.
    autorun((_) {
      if (_searchHistory.length > 8) _searchHistory.removeLast();
      prefs.setStringList('search_history', _searchHistory);
    });

    // Add a listener to update the cancel button visibility whenever the text changes.
    textEditingController.addListener(
      () => _searchText = textEditingController.text,
    );
  }

  /// Debounced handler for search-as-you-type.
  @action
  void onSearchTextChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _isSearching = false;
      _channelFuture = null;
      _categoryFuture = null;
      return;
    }

    // Show loading state immediately for responsive feedback.
    _isSearching = true;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      runInAction(() => _performSearch(query));
    });
  }

  /// Obtain the channels and categories that match the provided [query].
  /// Adds the query to search history.
  @action
  void handleQuery(String query) {
    if (query.isEmpty) return;

    // Cancel any pending debounce since we're searching immediately.
    _debounceTimer?.cancel();

    // Move the query to the most recent result (top of the stack).
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);

    _performSearch(query);
  }

  /// Performs the actual search API calls.
  @action
  void _performSearch(String query) {
    // Futures are now pending, so isSearching can be cleared.
    _isSearching = false;

    // Fetch the matching channels, sort it by live status, and then set it.
    _channelFuture = twitchApi.searchChannels(query: query).then((channels) {
      channels.sort((c1, c2) => c2.isLive ? 1 : -1);
      return channels;
    }).asObservable();

    // Fetch and set the categories that match the query.
    _categoryFuture = twitchApi.searchCategories(query: query).then((
      categories,
    ) {
      // Move exact matches to the first result
      final matchingIndex = categories.data.indexWhere(
        (c) => c.name.toLowerCase() == query.toLowerCase(),
      );
      if (matchingIndex >= 1) {
        final matchingCategory = categories.data.removeAt(matchingIndex);
        categories.data.insert(0, matchingCategory);
      }
      return categories;
    }).asObservable();
  }

  /// Find a specific channel provided the [query].
  /// This is used for channels that may not show up in the search results.
  Future<Channel> searchChannel(String query) async {
    final user = await twitchApi.getUser(userLogin: query);
    return await twitchApi.getChannel(userId: user.id);
  }

  void dispose() {
    _debounceTimer?.cancel();
    textEditingController.dispose();
    textFieldFocusNode.dispose();
  }
}

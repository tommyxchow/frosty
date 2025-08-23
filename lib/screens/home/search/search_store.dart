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

  @readonly
  var _searchText = '';

  @readonly
  var _searchHistory = ObservableList<String>();

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
    _searchHistory = prefs.getStringList('search_history')?.asObservable() ??
        ObservableList<String>();

    // Create a reaction that will limit the history to 8 entries and update it to local storage automatically.
    autorun((_) {
      if (_searchHistory.length > 8) _searchHistory.removeLast();
      prefs.setStringList('search_history', _searchHistory);
    });

    // Add a listener to update the cancel button visibility whenever the text changes.
    textEditingController
        .addListener(() => _searchText = textEditingController.text);
  }

  /// Obtain the channels and categories that match the provided [query].
  @action
  void handleQuery(String query) {
    if (query.isEmpty) return;

    // Move the query to the most recent result (top of the stack).
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);

    // Fetch the matching channels, sort it by live status, and then set it.
    _channelFuture = twitchApi
        .searchChannels(
      query: query,
      headers: authStore.headersTwitch,
    )
        .then(
      (channels) {
        channels.sort((c1, c2) => c2.isLive ? 1 : -1);
        return channels;
      },
    ).asObservable();

    // Fetch and set the categories that match the query.
    _categoryFuture = twitchApi
        .searchCategories(
      query: query,
      headers: authStore.headersTwitch,
    )
        .then((categories) {
      // Move exact matches to the first result
      final matchingIndex = categories.data
          .indexWhere((c) => c.name.toLowerCase() == query.toLowerCase());
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
    final user = await twitchApi.getUser(
      userLogin: query,
      headers: authStore.headersTwitch,
    );
    return await twitchApi.getChannel(
      userId: user.id,
      headers: authStore.headersTwitch,
    );
  }

  void dispose() {
    textEditingController.dispose();
    textFieldFocusNode.dispose();
  }
}

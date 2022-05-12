import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/models/channel.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_store.g.dart';

class SearchStore = SearchStoreBase with _$SearchStore;

abstract class SearchStoreBase with Store {
  final AuthStore authStore;

  final TwitchApi twitchApi;

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

    _categoryFuture = twitchApi
        .searchCategories(
          query: query,
          headers: authStore.headersTwitch,
        )
        .asObservable();
  }

  Future<Channel> searchChannel(String query) async {
    final user = await twitchApi.getUser(userLogin: query, headers: authStore.headersTwitch);
    return await twitchApi.getChannel(userId: user.id, headers: authStore.headersTwitch);
  }
}

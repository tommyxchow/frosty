import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/models/stream.dart';
import 'package:mobx/mobx.dart';

part 'list_store.g.dart';

class ListStore = _ListStoreBase with _$ListStore;

abstract class _ListStoreBase with Store {
  /// The list of the fetched streams.
  @readonly
  var _streams = ObservableList<StreamTwitch>();

  @readonly
  var _categories = ObservableList<CategoryTwitch>();

  /// The loading status for pagination.
  @readonly
  bool _isLoading = false;

  /// The pagination cursor for the streams.
  String? _currentCursor;

  StreamListType listType;

  final CategoryTwitch? categoryInfo;

  /// The authentication store.
  final AuthStore authStore;

  /// Returns whether or not there are more streams and loading status for pagination.
  bool get hasMore => _isLoading == false && _currentCursor != null;

  _ListStoreBase({
    required this.authStore,
    required this.listType,
    this.categoryInfo,
  }) {
    switch (listType) {
      case StreamListType.followed:
        if (listType == StreamListType.followed && authStore.isLoggedIn) {
          getData();
        }
        break;
      case StreamListType.top:
      case StreamListType.category:
        getData();
        break;
      case StreamListType.categories:
        getGames();
        break;
    }
  }

  /// Fetches the streams based on the type and current cursor.
  @action
  Future<void> getData() async {
    _isLoading = true;

    final StreamsTwitch? newStreams;
    switch (listType) {
      case StreamListType.followed:
        newStreams = await Twitch.getFollowedStreams(
          id: authStore.user.details!.id,
          headers: authStore.headersTwitch,
          cursor: _currentCursor,
        );
        break;
      case StreamListType.top:
        newStreams = await Twitch.getTopStreams(
          headers: authStore.headersTwitch,
          cursor: _currentCursor,
        );
        break;
      case StreamListType.category:
        newStreams = await Twitch.getStreamsUnderGame(
          gameId: categoryInfo!.id,
          headers: authStore.headersTwitch,
          cursor: _currentCursor,
        );
        break;
      case StreamListType.categories:
        return getGames();
    }

    if (newStreams != null) {
      if (_currentCursor == null) {
        _streams = newStreams.data.asObservable();
      } else {
        _streams.addAll(newStreams.data);
      }
      _currentCursor = newStreams.pagination['cursor'];
    }

    _isLoading = false;
  }

  // Fetches the top categories based on the current cursor.
  @action
  Future<void> getGames() async {
    final result = await Twitch.getTopGames(headers: authStore.headersTwitch, cursor: _currentCursor);
    if (result != null) {
      if (_currentCursor == null) {
        _categories = result.data.asObservable();
      } else {
        _categories.addAll(result.data);
      }
      _currentCursor = result.pagination['cursor'];
    }

    _isLoading = false;
  }

  /// Resets the cursor and then fetches the streams.
  @action
  Future<void> refresh() {
    _currentCursor = null;

    return getData();
  }
}

enum StreamListType {
  followed,
  top,
  category,
  categories,
}

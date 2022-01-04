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
  String? _streamsCursor;

  /// The pagination cursor for the categories.
  String? _categoriesCursor;

  final CategoryTwitch? categoryInfo;

  final ListType listType;

  /// The authentication store.
  final AuthStore authStore;

  /// Returns whether or not there are more streams and loading status for pagination.
  bool get hasMore => _isLoading == false && _streamsCursor != null;

  _ListStoreBase({
    required this.authStore,
    required this.listType,
    this.categoryInfo,
  }) {
    switch (listType) {
      case ListType.followed:
        if (listType == ListType.followed && authStore.isLoggedIn) getStreams();
        break;
      case ListType.top:
        getStreams();
        getCategories();
        break;
      case ListType.category:
        getStreams();
        break;
    }
  }

  /// Fetches the streams based on the type and current cursor.
  @action
  Future<void> getStreams() async {
    _isLoading = true;

    final StreamsTwitch? newStreams;
    switch (listType) {
      case ListType.followed:
        newStreams = await Twitch.getFollowedStreams(
          id: authStore.user.details!.id,
          headers: authStore.headersTwitch,
          cursor: _streamsCursor,
        );
        break;
      case ListType.top:
        newStreams = await Twitch.getTopStreams(
          headers: authStore.headersTwitch,
          cursor: _streamsCursor,
        );
        break;
      case ListType.category:
        newStreams = await Twitch.getStreamsUnderGame(
          gameId: categoryInfo!.id,
          headers: authStore.headersTwitch,
          cursor: _streamsCursor,
        );
        break;
    }

    if (newStreams != null) {
      if (_streamsCursor == null) {
        _streams = newStreams.data.asObservable();
      } else {
        _streams.addAll(newStreams.data);
      }
      _streamsCursor = newStreams.pagination['cursor'];
    }

    _isLoading = false;
  }

  // Fetches the top categories based on the current cursor.
  @action
  Future<void> getCategories() async {
    _isLoading = true;

    final result = await Twitch.getTopGames(headers: authStore.headersTwitch, cursor: _categoriesCursor);
    if (result != null) {
      if (_categoriesCursor == null) {
        _categories = result.data.asObservable();
      } else {
        _categories.addAll(result.data);
      }
      _categoriesCursor = result.pagination['cursor'];
    }

    _isLoading = false;
  }

  /// Resets the cursor and then fetches the streams.
  @action
  Future<void> refreshStreams() {
    _streamsCursor = null;

    return getStreams();
  }

  /// Resets the cursor and then fetches the categories.
  @action
  Future<void> refreshCategories() {
    _categoriesCursor = null;

    return getCategories();
  }
}

enum ListType {
  followed,
  top,
  category,
}

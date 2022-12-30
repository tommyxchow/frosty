import 'dart:io';

import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:mobx/mobx.dart';

part 'categories_store.g.dart';

class CategoriesStore = CategoriesStoreBase with _$CategoriesStore;

abstract class CategoriesStoreBase with Store {
  /// The authentication store.
  final AuthStore authStore;

  /// Twitch API service class for making requests.
  final TwitchApi twitchApi;

  /// The pagination cursor for the categories.
  String? _categoriesCursor;

  /// The last time the categories were refreshed/updated.
  var lastTimeRefreshed = DateTime.now();

  /// The loading status for pagination.
  @readonly
  bool _isLoading = false;

  /// The current visible categories, sorted by total viewers.
  @readonly
  var _categories = ObservableList<CategoryTwitch>();

  /// The error message to show if any. Will be non-null if there is an error.
  @readonly
  String? _error;

  /// Returns whether or not there are more streams and loading status for pagination.
  @computed
  bool get hasMore => _isLoading == false && _categoriesCursor != null;

  CategoriesStoreBase({required this.authStore, required this.twitchApi}) {
    getCategories();
  }

  // Fetches the top categories based on the current cursor.
  @action
  Future<void> getCategories() async {
    _isLoading = true;

    try {
      final result = await twitchApi.getTopCategories(
        headers: authStore.headersTwitch,
        cursor: _categoriesCursor,
      );

      if (_categoriesCursor == null) {
        _categories = result.data.asObservable();
      } else {
        _categories.addAll(result.data);
      }
      _categoriesCursor = result.pagination?['cursor'];

      _error = null;
    } on SocketException {
      _error = 'Failed to connect';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
  }

  /// Resets the cursor and then fetches the categories.
  @action
  Future<void> refreshCategories() {
    _categoriesCursor = null;

    return getCategories();
  }

  /// Checks the last time the categories were refreshed and updates them if it has been more than 5 minutes.
  void checkLastTimeRefreshedAndUpdate() {
    final now = DateTime.now();
    final difference = now.difference(lastTimeRefreshed);

    if (difference.inMinutes >= 5) refreshCategories();

    lastTimeRefreshed = now;
  }
}

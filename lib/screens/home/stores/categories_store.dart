import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:mobx/mobx.dart';
part 'categories_store.g.dart';

class CategoriesStore = _CategoriesStoreBase with _$CategoriesStore;

abstract class _CategoriesStoreBase with Store {
  /// The authentication store.
  final AuthStore authStore;

  final scrollController = ScrollController();

  /// The pagination cursor for the categories.
  String? _categoriesCursor;

  @observable
  var showJumpButton = false;

  @readonly
  var _categories = ObservableList<CategoryTwitch>();

  /// The loading status for pagination.
  @readonly
  bool _isLoading = false;

  /// Returns whether or not there are more streams and loading status for pagination.
  bool get hasMore => _isLoading == false && _categoriesCursor != null;

  _CategoriesStoreBase({required this.authStore}) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge || scrollController.position.outOfRange) {
        showJumpButton = false;
      } else {
        showJumpButton = true;
      }
    });
    getCategories();
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

  /// Resets the cursor and then fetches the categories.
  @action
  Future<void> refreshCategories() {
    _categoriesCursor = null;

    return getCategories();
  }

  void dispose() {
    scrollController.dispose();
  }
}

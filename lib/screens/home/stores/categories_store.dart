import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
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

  /// The loading status for pagination.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Returns whether or not there are more streams and loading status for pagination.
  bool get hasMore => _isLoading == false && _categoriesCursor != null;

  /// The scroll controller used for handling scroll to top.
  final scrollController = ScrollController();

  /// Whether or not the scroll to top button is visible.
  @observable
  var showJumpButton = false;

  /// The current visible categories, sorted by total viewers.
  @readonly
  var _categories = ObservableList<CategoryTwitch>();

  /// The error message to show if any. Will be non-null if there is an error.
  @readonly
  String? _error;

  CategoriesStoreBase({required this.authStore, required this.twitchApi}) {
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

  void dispose() {
    scrollController.dispose();
  }
}

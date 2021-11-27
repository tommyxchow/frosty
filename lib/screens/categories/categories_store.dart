import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:mobx/mobx.dart';

part 'categories_store.g.dart';

class CategoriesStore = _CategoriesStoreBase with _$CategoriesStore;

abstract class _CategoriesStoreBase with Store {
  final AuthStore authStore;

  final categories = ObservableList<CategoryTwitch>();

  String? _currentCursor;

  var _isLoading = false;

  bool get hasMore => _isLoading == false && _currentCursor != null;

  _CategoriesStoreBase({required this.authStore}) {
    getGames();
  }

  @action
  Future<void> getGames() async {
    _isLoading = true;

    final result = await Twitch.getTopGames(headers: authStore.headersTwitch, cursor: _currentCursor);
    if (result != null) {
      categories.addAll(result.data);
      _currentCursor = result.pagination['cursor'];
    }

    _isLoading = false;
  }

  @action
  Future<void> refresh() async {
    _currentCursor = null;

    getGames();
  }
}

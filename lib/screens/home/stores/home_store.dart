import 'package:frosty/core/auth/auth_store.dart';
import 'package:mobx/mobx.dart';
part 'home_store.g.dart';

class HomeStore = _HomeStoreBase with _$HomeStore;

abstract class _HomeStoreBase with Store {
  final AuthStore authStore;

  late final ReactionDisposer _disposeReaction;

  _HomeStoreBase({required this.authStore}) {
    _disposeReaction = reaction(
      (_) => authStore.isLoggedIn,
      (_) => _selectedIndex = 0,
    );
  }

  @readonly
  var _selectedIndex = 0;

  @action
  void handleTap(int index) {
    if (index != _selectedIndex) {
      _selectedIndex = index;
    }
  }

  void dispose() => _disposeReaction();
}

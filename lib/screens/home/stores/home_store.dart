import 'package:mobx/mobx.dart';
part 'home_store.g.dart';

class HomeStore = _HomeStoreBase with _$HomeStore;

abstract class _HomeStoreBase with Store {
  @readonly
  var _selectedIndex = 0;

  @action
  void handleTap(int index) {
    if (index != _selectedIndex) {
      _selectedIndex = index;
    }
  }
}

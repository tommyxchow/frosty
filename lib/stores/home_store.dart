import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

class HomeStore = _HomeStoreBase with _$HomeStore;

abstract class _HomeStoreBase with Store {
  @observable
  bool search = false;

  @observable
  int selectedIndex = 0;

  @action
  void handleTap(int index) {
    if (index != selectedIndex) {
      selectedIndex = index;
    }
  }
}

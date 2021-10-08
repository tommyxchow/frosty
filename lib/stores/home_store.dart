import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

class HomeStore = _HomeStoreBase with _$HomeStore;

abstract class _HomeStoreBase with Store {
  @observable
  int selectedIndex = 0;

  @action
  void handleTap(int index) {
    selectedIndex = index;
  }
}

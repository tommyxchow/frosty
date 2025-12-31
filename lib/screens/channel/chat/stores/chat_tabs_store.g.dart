// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_tabs_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChatTabsStore on ChatTabsStoreBase, Store {
  Computed<ChatTabInfo>? _$activeTabComputed;

  @override
  ChatTabInfo get activeTab => (_$activeTabComputed ??= Computed<ChatTabInfo>(
    () => super.activeTab,
    name: 'ChatTabsStoreBase.activeTab',
  )).value;
  Computed<ChatStore>? _$activeChatStoreComputed;

  @override
  ChatStore get activeChatStore =>
      (_$activeChatStoreComputed ??= Computed<ChatStore>(
        () => super.activeChatStore,
        name: 'ChatTabsStoreBase.activeChatStore',
      )).value;
  Computed<bool>? _$canAddTabComputed;

  @override
  bool get canAddTab => (_$canAddTabComputed ??= Computed<bool>(
    () => super.canAddTab,
    name: 'ChatTabsStoreBase.canAddTab',
  )).value;
  Computed<bool>? _$showTabBarComputed;

  @override
  bool get showTabBar => (_$showTabBarComputed ??= Computed<bool>(
    () => super.showTabBar,
    name: 'ChatTabsStoreBase.showTabBar',
  )).value;

  late final _$_tabsAtom = Atom(
    name: 'ChatTabsStoreBase._tabs',
    context: context,
  );

  ObservableList<ChatTabInfo> get tabs {
    _$_tabsAtom.reportRead();
    return super._tabs;
  }

  @override
  ObservableList<ChatTabInfo> get _tabs => tabs;

  @override
  set _tabs(ObservableList<ChatTabInfo> value) {
    _$_tabsAtom.reportWrite(value, super._tabs, () {
      super._tabs = value;
    });
  }

  late final _$activeTabIndexAtom = Atom(
    name: 'ChatTabsStoreBase.activeTabIndex',
    context: context,
  );

  @override
  int get activeTabIndex {
    _$activeTabIndexAtom.reportRead();
    return super.activeTabIndex;
  }

  @override
  set activeTabIndex(int value) {
    _$activeTabIndexAtom.reportWrite(value, super.activeTabIndex, () {
      super.activeTabIndex = value;
    });
  }

  late final _$ChatTabsStoreBaseActionController = ActionController(
    name: 'ChatTabsStoreBase',
    context: context,
  );

  @override
  bool addTab({
    required String channelId,
    required String channelLogin,
    required String displayName,
  }) {
    final _$actionInfo = _$ChatTabsStoreBaseActionController.startAction(
      name: 'ChatTabsStoreBase.addTab',
    );
    try {
      return super.addTab(
        channelId: channelId,
        channelLogin: channelLogin,
        displayName: displayName,
      );
    } finally {
      _$ChatTabsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  bool removeTab(int index) {
    final _$actionInfo = _$ChatTabsStoreBaseActionController.startAction(
      name: 'ChatTabsStoreBase.removeTab',
    );
    try {
      return super.removeTab(index);
    } finally {
      _$ChatTabsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setActiveTab(int index) {
    final _$actionInfo = _$ChatTabsStoreBaseActionController.startAction(
      name: 'ChatTabsStoreBase.setActiveTab',
    );
    try {
      return super.setActiveTab(index);
    } finally {
      _$ChatTabsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
activeTabIndex: ${activeTabIndex},
activeTab: ${activeTab},
activeChatStore: ${activeChatStore},
canAddTab: ${canAddTab},
showTabBar: ${showTabBar}
    ''';
  }
}

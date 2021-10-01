// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChatStore on _ChatStoreBase, Store {
  final _$autoScrollAtom = Atom(name: '_ChatStoreBase.autoScroll');

  @override
  bool get autoScroll {
    _$autoScrollAtom.reportRead();
    return super.autoScroll;
  }

  @override
  set autoScroll(bool value) {
    _$autoScrollAtom.reportWrite(value, super.autoScroll, () {
      super.autoScroll = value;
    });
  }

  final _$_ChatStoreBaseActionController =
      ActionController(name: '_ChatStoreBase');

  @override
  void handleWebsocketData(Object? data) {
    final _$actionInfo = _$_ChatStoreBaseActionController.startAction(
        name: '_ChatStoreBase.handleWebsocketData');
    try {
      return super.handleWebsocketData(data);
    } finally {
      _$_ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resumeScroll() {
    final _$actionInfo = _$_ChatStoreBaseActionController.startAction(
        name: '_ChatStoreBase.resumeScroll');
    try {
      return super.resumeScroll();
    } finally {
      _$_ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
autoScroll: ${autoScroll}
    ''';
  }
}

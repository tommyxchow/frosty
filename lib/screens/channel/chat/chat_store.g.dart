// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChatStore on _ChatStoreBase, Store {
  final _$_autoScrollAtom = Atom(name: '_ChatStoreBase._autoScroll');

  bool get autoScroll {
    _$_autoScrollAtom.reportRead();
    return super._autoScroll;
  }

  @override
  bool get _autoScroll => autoScroll;

  @override
  set _autoScroll(bool value) {
    _$_autoScrollAtom.reportWrite(value, super._autoScroll, () {
      super._autoScroll = value;
    });
  }

  final _$_roomStateAtom = Atom(name: '_ChatStoreBase._roomState');

  ROOMSTATE get roomState {
    _$_roomStateAtom.reportRead();
    return super._roomState;
  }

  @override
  ROOMSTATE get _roomState => roomState;

  @override
  set _roomState(ROOMSTATE value) {
    _$_roomStateAtom.reportWrite(value, super._roomState, () {
      super._roomState = value;
    });
  }

  final _$_ChatStoreBaseActionController =
      ActionController(name: '_ChatStoreBase');

  @override
  void _handleIRCData(String data) {
    final _$actionInfo = _$_ChatStoreBaseActionController.startAction(
        name: '_ChatStoreBase._handleIRCData');
    try {
      return super._handleIRCData(data);
    } finally {
      _$_ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _deleteAndScrollToEnd() {
    final _$actionInfo = _$_ChatStoreBaseActionController.startAction(
        name: '_ChatStoreBase._deleteAndScrollToEnd');
    try {
      return super._deleteAndScrollToEnd();
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

    ''';
  }
}

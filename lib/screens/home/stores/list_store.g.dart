// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ListStore on _ListStoreBase, Store {
  final _$showJumpButtonAtom = Atom(name: '_ListStoreBase.showJumpButton');

  @override
  bool get showJumpButton {
    _$showJumpButtonAtom.reportRead();
    return super.showJumpButton;
  }

  @override
  set showJumpButton(bool value) {
    _$showJumpButtonAtom.reportWrite(value, super.showJumpButton, () {
      super.showJumpButton = value;
    });
  }

  final _$_streamsAtom = Atom(name: '_ListStoreBase._streams');

  ObservableList<StreamTwitch> get streams {
    _$_streamsAtom.reportRead();
    return super._streams;
  }

  @override
  ObservableList<StreamTwitch> get _streams => streams;

  @override
  set _streams(ObservableList<StreamTwitch> value) {
    _$_streamsAtom.reportWrite(value, super._streams, () {
      super._streams = value;
    });
  }

  final _$_errorAtom = Atom(name: '_ListStoreBase._error');

  String? get error {
    _$_errorAtom.reportRead();
    return super._error;
  }

  @override
  String? get _error => error;

  @override
  set _error(String? value) {
    _$_errorAtom.reportWrite(value, super._error, () {
      super._error = value;
    });
  }

  final _$getStreamsAsyncAction = AsyncAction('_ListStoreBase.getStreams');

  @override
  Future<void> getStreams() {
    return _$getStreamsAsyncAction.run(() => super.getStreams());
  }

  final _$_ListStoreBaseActionController =
      ActionController(name: '_ListStoreBase');

  @override
  Future<void> refreshStreams() {
    final _$actionInfo = _$_ListStoreBaseActionController.startAction(
        name: '_ListStoreBase.refreshStreams');
    try {
      return super.refreshStreams();
    } finally {
      _$_ListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
showJumpButton: ${showJumpButton}
    ''';
  }
}

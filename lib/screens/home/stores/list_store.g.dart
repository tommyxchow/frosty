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

  final _$_isLoadingAtom = Atom(name: '_ListStoreBase._isLoading');

  bool get isLoading {
    _$_isLoadingAtom.reportRead();
    return super._isLoading;
  }

  @override
  bool get _isLoading => isLoading;

  @override
  set _isLoading(bool value) {
    _$_isLoadingAtom.reportWrite(value, super._isLoading, () {
      super._isLoading = value;
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

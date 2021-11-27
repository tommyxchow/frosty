// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_streams_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopStreamsStore on _TopStreamsStoreBase, Store {
  final _$_topStreamsAtom = Atom(name: '_TopStreamsStoreBase._topStreams');

  @override
  ObservableList<StreamTwitch> get _topStreams {
    _$_topStreamsAtom.reportRead();
    return super._topStreams;
  }

  @override
  set _topStreams(ObservableList<StreamTwitch> value) {
    _$_topStreamsAtom.reportWrite(value, super._topStreams, () {
      super._topStreams = value;
    });
  }

  final _$getTopStreamsAsyncAction =
      AsyncAction('_TopStreamsStoreBase.getTopStreams');

  @override
  Future<void> getTopStreams() {
    return _$getTopStreamsAsyncAction.run(() => super.getTopStreams());
  }

  final _$_TopStreamsStoreBaseActionController =
      ActionController(name: '_TopStreamsStoreBase');

  @override
  Future<void> refresh() {
    final _$actionInfo = _$_TopStreamsStoreBaseActionController.startAction(
        name: '_TopStreamsStoreBase.refresh');
    try {
      return super.refresh();
    } finally {
      _$_TopStreamsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}

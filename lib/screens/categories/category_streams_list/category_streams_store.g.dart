// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_streams_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$CategoryStreamsStore on _CategoryStreamsStoreBase, Store {
  final _$_streamsAtom = Atom(name: '_CategoryStreamsStoreBase._streams');

  @override
  ObservableList<StreamTwitch> get _streams {
    _$_streamsAtom.reportRead();
    return super._streams;
  }

  @override
  set _streams(ObservableList<StreamTwitch> value) {
    _$_streamsAtom.reportWrite(value, super._streams, () {
      super._streams = value;
    });
  }

  final _$getStreamsAsyncAction =
      AsyncAction('_CategoryStreamsStoreBase.getStreams');

  @override
  Future<void> getStreams() {
    return _$getStreamsAsyncAction.run(() => super.getStreams());
  }

  final _$refreshAsyncAction = AsyncAction('_CategoryStreamsStoreBase.refresh');

  @override
  Future<void> refresh() {
    return _$refreshAsyncAction.run(() => super.refresh());
  }

  @override
  String toString() {
    return '''

    ''';
  }
}

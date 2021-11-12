// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StreamListStore on _StreamListBase, Store {
  final _$_topStreamsAtom = Atom(name: '_StreamListBase._topStreams');

  @override
  ObservableList<Stream> get _topStreams {
    _$_topStreamsAtom.reportRead();
    return super._topStreams;
  }

  @override
  set _topStreams(ObservableList<Stream> value) {
    _$_topStreamsAtom.reportWrite(value, super._topStreams, () {
      super._topStreams = value;
    });
  }

  final _$_followedStreamsAtom = Atom(name: '_StreamListBase._followedStreams');

  @override
  ObservableList<Stream> get _followedStreams {
    _$_followedStreamsAtom.reportRead();
    return super._followedStreams;
  }

  @override
  set _followedStreams(ObservableList<Stream> value) {
    _$_followedStreamsAtom.reportWrite(value, super._followedStreams, () {
      super._followedStreams = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_StreamListBase.refresh');

  @override
  Future<void> refresh({required StreamCategory category}) {
    return _$refreshAsyncAction.run(() => super.refresh(category: category));
  }

  final _$getStreamsAsyncAction = AsyncAction('_StreamListBase.getStreams');

  @override
  Future<void> getStreams({required StreamCategory category}) {
    return _$getStreamsAsyncAction
        .run(() => super.getStreams(category: category));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}

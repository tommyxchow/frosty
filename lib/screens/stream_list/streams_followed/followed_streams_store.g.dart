// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followed_streams_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$FollowedStreamsStore on _FollowedStreamsStoreBase, Store {
  final _$_followedStreamsAtom =
      Atom(name: '_FollowedStreamsStoreBase._followedStreams');

  @override
  ObservableList<StreamTwitch> get _followedStreams {
    _$_followedStreamsAtom.reportRead();
    return super._followedStreams;
  }

  @override
  set _followedStreams(ObservableList<StreamTwitch> value) {
    _$_followedStreamsAtom.reportWrite(value, super._followedStreams, () {
      super._followedStreams = value;
    });
  }

  final _$getFollowedStreamsAsyncAction =
      AsyncAction('_FollowedStreamsStoreBase.getFollowedStreams');

  @override
  Future<void> getFollowedStreams() {
    return _$getFollowedStreamsAsyncAction
        .run(() => super.getFollowedStreams());
  }

  final _$refreshAsyncAction = AsyncAction('_FollowedStreamsStoreBase.refresh');

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

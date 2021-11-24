// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VideoStore on _VideoStoreBase, Store {
  final _$menuVisibleAtom = Atom(name: '_VideoStoreBase.menuVisible');

  @override
  bool get menuVisible {
    _$menuVisibleAtom.reportRead();
    return super.menuVisible;
  }

  @override
  set menuVisible(bool value) {
    _$menuVisibleAtom.reportWrite(value, super.menuVisible, () {
      super.menuVisible = value;
    });
  }

  final _$pausedAtom = Atom(name: '_VideoStoreBase.paused');

  @override
  bool get paused {
    _$pausedAtom.reportRead();
    return super.paused;
  }

  @override
  set paused(bool value) {
    _$pausedAtom.reportWrite(value, super.paused, () {
      super.paused = value;
    });
  }

  final _$streamInfoAtom = Atom(name: '_VideoStoreBase.streamInfo');

  @override
  StreamTwitch? get streamInfo {
    _$streamInfoAtom.reportRead();
    return super.streamInfo;
  }

  @override
  set streamInfo(StreamTwitch? value) {
    _$streamInfoAtom.reportWrite(value, super.streamInfo, () {
      super.streamInfo = value;
    });
  }

  final _$updateStreamInfoAsyncAction =
      AsyncAction('_VideoStoreBase.updateStreamInfo');

  @override
  Future<void> updateStreamInfo() {
    return _$updateStreamInfoAsyncAction.run(() => super.updateStreamInfo());
  }

  final _$_VideoStoreBaseActionController =
      ActionController(name: '_VideoStoreBase');

  @override
  void handlePausePlay() {
    final _$actionInfo = _$_VideoStoreBaseActionController.startAction(
        name: '_VideoStoreBase.handlePausePlay');
    try {
      return super.handlePausePlay();
    } finally {
      _$_VideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void handleVideoTap() {
    final _$actionInfo = _$_VideoStoreBaseActionController.startAction(
        name: '_VideoStoreBase.handleVideoTap');
    try {
      return super.handleVideoTap();
    } finally {
      _$_VideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
menuVisible: ${menuVisible},
paused: ${paused},
streamInfo: ${streamInfo}
    ''';
  }
}

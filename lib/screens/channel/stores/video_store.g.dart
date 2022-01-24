// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VideoStore on _VideoStoreBase, Store {
  Computed<String>? _$videoUrlComputed;

  @override
  String get videoUrl =>
      (_$videoUrlComputed ??= Computed<String>(() => super.videoUrl,
              name: '_VideoStoreBase.videoUrl'))
          .value;

  final _$_pausedAtom = Atom(name: '_VideoStoreBase._paused');

  bool get paused {
    _$_pausedAtom.reportRead();
    return super._paused;
  }

  @override
  bool get _paused => paused;

  @override
  set _paused(bool value) {
    _$_pausedAtom.reportWrite(value, super._paused, () {
      super._paused = value;
    });
  }

  final _$_overlayVisibleAtom = Atom(name: '_VideoStoreBase._overlayVisible');

  bool get overlayVisible {
    _$_overlayVisibleAtom.reportRead();
    return super._overlayVisible;
  }

  @override
  bool get _overlayVisible => overlayVisible;

  @override
  set _overlayVisible(bool value) {
    _$_overlayVisibleAtom.reportWrite(value, super._overlayVisible, () {
      super._overlayVisible = value;
    });
  }

  final _$_streamInfoAtom = Atom(name: '_VideoStoreBase._streamInfo');

  StreamTwitch? get streamInfo {
    _$_streamInfoAtom.reportRead();
    return super._streamInfo;
  }

  @override
  StreamTwitch? get _streamInfo => streamInfo;

  @override
  set _streamInfo(StreamTwitch? value) {
    _$_streamInfoAtom.reportWrite(value, super._streamInfo, () {
      super._streamInfo = value;
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
  void handleExpand() {
    final _$actionInfo = _$_VideoStoreBaseActionController.startAction(
        name: '_VideoStoreBase.handleExpand');
    try {
      return super.handleExpand();
    } finally {
      _$_VideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void handleToggleOverlay() {
    final _$actionInfo = _$_VideoStoreBaseActionController.startAction(
        name: '_VideoStoreBase.handleToggleOverlay');
    try {
      return super.handleToggleOverlay();
    } finally {
      _$_VideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
videoUrl: ${videoUrl}
    ''';
  }
}

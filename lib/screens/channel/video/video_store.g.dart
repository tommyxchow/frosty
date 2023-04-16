// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VideoStore on VideoStoreBase, Store {
  Computed<String>? _$videoUrlComputed;

  @override
  String get videoUrl =>
      (_$videoUrlComputed ??= Computed<String>(() => super.videoUrl,
              name: 'VideoStoreBase.videoUrl'))
          .value;

  late final _$_videoPlayerControllerAtom =
      Atom(name: 'VideoStoreBase._videoPlayerController', context: context);

  BetterPlayerController? get videoPlayerController {
    _$_videoPlayerControllerAtom.reportRead();
    return super._videoPlayerController;
  }

  @override
  BetterPlayerController? get _videoPlayerController => videoPlayerController;

  @override
  set _videoPlayerController(BetterPlayerController? value) {
    _$_videoPlayerControllerAtom
        .reportWrite(value, super._videoPlayerController, () {
      super._videoPlayerController = value;
    });
  }

  late final _$_pausedAtom =
      Atom(name: 'VideoStoreBase._paused', context: context);

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

  late final _$_overlayVisibleAtom =
      Atom(name: 'VideoStoreBase._overlayVisible', context: context);

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

  late final _$_isIPadAtom =
      Atom(name: 'VideoStoreBase._isIPad', context: context);

  bool get isIPad {
    _$_isIPadAtom.reportRead();
    return super._isIPad;
  }

  @override
  bool get _isIPad => isIPad;

  @override
  set _isIPad(bool value) {
    _$_isIPadAtom.reportWrite(value, super._isIPad, () {
      super._isIPad = value;
    });
  }

  late final _$_streamInfoAtom =
      Atom(name: 'VideoStoreBase._streamInfo', context: context);

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

  late final _$_streamLinksAtom =
      Atom(name: 'VideoStoreBase._streamLinks', context: context);

  Map<String, String>? get streamLinks {
    _$_streamLinksAtom.reportRead();
    return super._streamLinks;
  }

  @override
  Map<String, String>? get _streamLinks => streamLinks;

  @override
  set _streamLinks(Map<String, String>? value) {
    _$_streamLinksAtom.reportWrite(value, super._streamLinks, () {
      super._streamLinks = value;
    });
  }

  late final _$_selectedQualityAtom =
      Atom(name: 'VideoStoreBase._selectedQuality', context: context);

  String get selectedQuality {
    _$_selectedQualityAtom.reportRead();
    return super._selectedQuality;
  }

  @override
  String get _selectedQuality => selectedQuality;

  @override
  set _selectedQuality(String value) {
    _$_selectedQualityAtom.reportWrite(value, super._selectedQuality, () {
      super._selectedQuality = value;
    });
  }

  late final _$initVideoAsyncAction =
      AsyncAction('VideoStoreBase.initVideo', context: context);

  @override
  Future<void> initVideo() {
    return _$initVideoAsyncAction.run(() => super.initVideo());
  }

  late final _$handleQualityChangeAsyncAction =
      AsyncAction('VideoStoreBase.handleQualityChange', context: context);

  @override
  Future<void> handleQualityChange(String quality) {
    return _$handleQualityChangeAsyncAction
        .run(() => super.handleQualityChange(quality));
  }

  late final _$updateStreamInfoAsyncAction =
      AsyncAction('VideoStoreBase.updateStreamInfo', context: context);

  @override
  Future<void> updateStreamInfo() {
    return _$updateStreamInfoAsyncAction.run(() => super.updateStreamInfo());
  }

  late final _$VideoStoreBaseActionController =
      ActionController(name: 'VideoStoreBase', context: context);

  @override
  void handleVideoTap() {
    final _$actionInfo = _$VideoStoreBaseActionController.startAction(
        name: 'VideoStoreBase.handleVideoTap');
    try {
      return super.handleVideoTap();
    } finally {
      _$VideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void handleToggleOverlay() {
    final _$actionInfo = _$VideoStoreBaseActionController.startAction(
        name: 'VideoStoreBase.handleToggleOverlay');
    try {
      return super.handleToggleOverlay();
    } finally {
      _$VideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void handleRefresh() {
    final _$actionInfo = _$VideoStoreBaseActionController.startAction(
        name: 'VideoStoreBase.handleRefresh');
    try {
      return super.handleRefresh();
    } finally {
      _$VideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dispose() {
    final _$actionInfo = _$VideoStoreBaseActionController.startAction(
        name: 'VideoStoreBase.dispose');
    try {
      return super.dispose();
    } finally {
      _$VideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
videoUrl: ${videoUrl}
    ''';
  }
}

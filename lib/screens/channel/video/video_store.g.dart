// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VideoStore on VideoStoreBase, Store {
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

  late final _$_availableStreamQualitiesAtom =
      Atom(name: 'VideoStoreBase._availableStreamQualities', context: context);

  List<String> get availableStreamQualities {
    _$_availableStreamQualitiesAtom.reportRead();
    return super._availableStreamQualities;
  }

  @override
  List<String> get _availableStreamQualities => availableStreamQualities;

  @override
  set _availableStreamQualities(List<String> value) {
    _$_availableStreamQualitiesAtom
        .reportWrite(value, super._availableStreamQualities, () {
      super._availableStreamQualities = value;
    });
  }

  late final _$_streamQualityIndexAtom =
      Atom(name: 'VideoStoreBase._streamQualityIndex', context: context);

  int get streamQualityIndex {
    _$_streamQualityIndexAtom.reportRead();
    return super._streamQualityIndex;
  }

  @override
  int get _streamQualityIndex => streamQualityIndex;

  @override
  set _streamQualityIndex(int value) {
    _$_streamQualityIndexAtom.reportWrite(value, super._streamQualityIndex, () {
      super._streamQualityIndex = value;
    });
  }

  late final _$_latencyAtom =
      Atom(name: 'VideoStoreBase._latency', context: context);

  String? get latency {
    _$_latencyAtom.reportRead();
    return super._latency;
  }

  @override
  String? get _latency => latency;

  @override
  set _latency(String? value) {
    _$_latencyAtom.reportWrite(value, super._latency, () {
      super._latency = value;
    });
  }

  late final _$updateStreamQualitiesAsyncAction =
      AsyncAction('VideoStoreBase.updateStreamQualities', context: context);

  @override
  Future<void> updateStreamQualities() {
    return _$updateStreamQualitiesAsyncAction
        .run(() => super.updateStreamQualities());
  }

  late final _$setStreamQualityAsyncAction =
      AsyncAction('VideoStoreBase.setStreamQuality', context: context);

  @override
  Future<void> setStreamQuality(String newStreamQuality) {
    return _$setStreamQualityAsyncAction
        .run(() => super.setStreamQuality(newStreamQuality));
  }

  late final _$_setStreamQualityIndexAsyncAction =
      AsyncAction('VideoStoreBase._setStreamQualityIndex', context: context);

  @override
  Future<void> _setStreamQualityIndex(int newStreamQualityIndex) {
    return _$_setStreamQualityIndexAsyncAction
        .run(() => super._setStreamQualityIndex(newStreamQualityIndex));
  }

  late final _$initVideoAsyncAction =
      AsyncAction('VideoStoreBase.initVideo', context: context);

  @override
  Future<void> initVideo() {
    return _$initVideoAsyncAction.run(() => super.initVideo());
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

    ''';
  }
}

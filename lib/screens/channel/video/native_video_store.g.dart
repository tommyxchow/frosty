// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_video_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NativeVideoStore on NativeVideoStoreBase, Store {
  Computed<String>? _$streamQualityComputed;

  @override
  String get streamQuality => (_$streamQualityComputed ??= Computed<String>(
    () => super.streamQuality,
    name: 'NativeVideoStoreBase.streamQuality',
  )).value;

  late final _$_controllerAtom = Atom(
    name: 'NativeVideoStoreBase._controller',
    context: context,
  );

  NativeVideoPlayerController? get controller {
    _$_controllerAtom.reportRead();
    return super._controller;
  }

  @override
  NativeVideoPlayerController? get _controller => controller;

  @override
  set _controller(NativeVideoPlayerController? value) {
    _$_controllerAtom.reportWrite(value, super._controller, () {
      super._controller = value;
    });
  }

  late final _$_loadingAtom = Atom(
    name: 'NativeVideoStoreBase._loading',
    context: context,
  );

  bool get loading {
    _$_loadingAtom.reportRead();
    return super._loading;
  }

  @override
  bool get _loading => loading;

  @override
  set _loading(bool value) {
    _$_loadingAtom.reportWrite(value, super._loading, () {
      super._loading = value;
    });
  }

  late final _$_pausedAtom = Atom(
    name: 'NativeVideoStoreBase._paused',
    context: context,
  );

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

  late final _$_overlayVisibleAtom = Atom(
    name: 'NativeVideoStoreBase._overlayVisible',
    context: context,
  );

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

  late final _$_streamInfoAtom = Atom(
    name: 'NativeVideoStoreBase._streamInfo',
    context: context,
  );

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

  late final _$_offlineChannelInfoAtom = Atom(
    name: 'NativeVideoStoreBase._offlineChannelInfo',
    context: context,
  );

  Channel? get offlineChannelInfo {
    _$_offlineChannelInfoAtom.reportRead();
    return super._offlineChannelInfo;
  }

  @override
  Channel? get _offlineChannelInfo => offlineChannelInfo;

  @override
  set _offlineChannelInfo(Channel? value) {
    _$_offlineChannelInfoAtom.reportWrite(value, super._offlineChannelInfo, () {
      super._offlineChannelInfo = value;
    });
  }

  late final _$_availableStreamQualitiesAtom = Atom(
    name: 'NativeVideoStoreBase._availableStreamQualities',
    context: context,
  );

  List<String> get availableStreamQualities {
    _$_availableStreamQualitiesAtom.reportRead();
    return super._availableStreamQualities;
  }

  @override
  List<String> get _availableStreamQualities => availableStreamQualities;

  @override
  set _availableStreamQualities(List<String> value) {
    _$_availableStreamQualitiesAtom.reportWrite(
      value,
      super._availableStreamQualities,
      () {
        super._availableStreamQualities = value;
      },
    );
  }

  late final _$_streamQualityIndexAtom = Atom(
    name: 'NativeVideoStoreBase._streamQualityIndex',
    context: context,
  );

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

  late final _$_latencyAtom = Atom(
    name: 'NativeVideoStoreBase._latency',
    context: context,
  );

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

  late final _$_isInPipModeAtom = Atom(
    name: 'NativeVideoStoreBase._isInPipMode',
    context: context,
  );

  bool get isInPipMode {
    _$_isInPipModeAtom.reportRead();
    return super._isInPipMode;
  }

  @override
  bool get _isInPipMode => isInPipMode;

  @override
  set _isInPipMode(bool value) {
    _$_isInPipModeAtom.reportWrite(value, super._isInPipMode, () {
      super._isInPipMode = value;
    });
  }

  late final _$_errorAtom = Atom(
    name: 'NativeVideoStoreBase._error',
    context: context,
  );

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

  late final _$_initPlayerAsyncAction = AsyncAction(
    'NativeVideoStoreBase._initPlayer',
    context: context,
  );

  @override
  Future<void> _initPlayer() {
    return _$_initPlayerAsyncAction.run(() => super._initPlayer());
  }

  late final _$handleRefreshAsyncAction = AsyncAction(
    'NativeVideoStoreBase.handleRefresh',
    context: context,
  );

  @override
  Future<void> handleRefresh() {
    return _$handleRefreshAsyncAction.run(() => super.handleRefresh());
  }

  late final _$updateStreamQualitiesAsyncAction = AsyncAction(
    'NativeVideoStoreBase.updateStreamQualities',
    context: context,
  );

  @override
  Future<void> updateStreamQualities() {
    return _$updateStreamQualitiesAsyncAction.run(
      () => super.updateStreamQualities(),
    );
  }

  late final _$setStreamQualityAsyncAction = AsyncAction(
    'NativeVideoStoreBase.setStreamQuality',
    context: context,
  );

  @override
  Future<void> setStreamQuality(String quality) {
    return _$setStreamQualityAsyncAction.run(
      () => super.setStreamQuality(quality),
    );
  }

  late final _$_setStreamQualityIndexAsyncAction = AsyncAction(
    'NativeVideoStoreBase._setStreamQualityIndex',
    context: context,
  );

  @override
  Future<void> _setStreamQualityIndex(int index) {
    return _$_setStreamQualityIndexAsyncAction.run(
      () => super._setStreamQualityIndex(index),
    );
  }

  late final _$updateStreamInfoAsyncAction = AsyncAction(
    'NativeVideoStoreBase.updateStreamInfo',
    context: context,
  );

  @override
  Future<void> updateStreamInfo({bool forceUpdate = false}) {
    return _$updateStreamInfoAsyncAction.run(
      () => super.updateStreamInfo(forceUpdate: forceUpdate),
    );
  }

  late final _$NativeVideoStoreBaseActionController = ActionController(
    name: 'NativeVideoStoreBase',
    context: context,
  );

  @override
  void handleVideoTap() {
    final _$actionInfo = _$NativeVideoStoreBaseActionController.startAction(
      name: 'NativeVideoStoreBase.handleVideoTap',
    );
    try {
      return super.handleVideoTap();
    } finally {
      _$NativeVideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void handleToggleOverlay() {
    final _$actionInfo = _$NativeVideoStoreBaseActionController.startAction(
      name: 'NativeVideoStoreBase.handleToggleOverlay',
    );
    try {
      return super.handleToggleOverlay();
    } finally {
      _$NativeVideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void togglePictureInPicture() {
    final _$actionInfo = _$NativeVideoStoreBaseActionController.startAction(
      name: 'NativeVideoStoreBase.togglePictureInPicture',
    );
    try {
      return super.togglePictureInPicture();
    } finally {
      _$NativeVideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void handleAppResume() {
    final _$actionInfo = _$NativeVideoStoreBaseActionController.startAction(
      name: 'NativeVideoStoreBase.handleAppResume',
    );
    try {
      return super.handleAppResume();
    } finally {
      _$NativeVideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dispose() {
    final _$actionInfo = _$NativeVideoStoreBaseActionController.startAction(
      name: 'NativeVideoStoreBase.dispose',
    );
    try {
      return super.dispose();
    } finally {
      _$NativeVideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
streamQuality: ${streamQuality}
    ''';
  }
}

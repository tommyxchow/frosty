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

  late final _$sleepHoursAtom =
      Atom(name: 'VideoStoreBase.sleepHours', context: context);

  @override
  int get sleepHours {
    _$sleepHoursAtom.reportRead();
    return super.sleepHours;
  }

  @override
  set sleepHours(int value) {
    _$sleepHoursAtom.reportWrite(value, super.sleepHours, () {
      super.sleepHours = value;
    });
  }

  late final _$sleepMinutesAtom =
      Atom(name: 'VideoStoreBase.sleepMinutes', context: context);

  @override
  int get sleepMinutes {
    _$sleepMinutesAtom.reportRead();
    return super.sleepMinutes;
  }

  @override
  set sleepMinutes(int value) {
    _$sleepMinutesAtom.reportWrite(value, super.sleepMinutes, () {
      super.sleepMinutes = value;
    });
  }

  late final _$timeRemainingAtom =
      Atom(name: 'VideoStoreBase.timeRemaining', context: context);

  @override
  Duration get timeRemaining {
    _$timeRemainingAtom.reportRead();
    return super.timeRemaining;
  }

  @override
  set timeRemaining(Duration value) {
    _$timeRemainingAtom.reportWrite(value, super.timeRemaining, () {
      super.timeRemaining = value;
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
  void handleExpand() {
    final _$actionInfo = _$VideoStoreBaseActionController.startAction(
        name: 'VideoStoreBase.handleExpand');
    try {
      return super.handleExpand();
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
  void updateSleepTimer({required void Function() onTimerFinished}) {
    final _$actionInfo = _$VideoStoreBaseActionController.startAction(
        name: 'VideoStoreBase.updateSleepTimer');
    try {
      return super.updateSleepTimer(onTimerFinished: onTimerFinished);
    } finally {
      _$VideoStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void cancelSleepTimer() {
    final _$actionInfo = _$VideoStoreBaseActionController.startAction(
        name: 'VideoStoreBase.cancelSleepTimer');
    try {
      return super.cancelSleepTimer();
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
sleepHours: ${sleepHours},
sleepMinutes: ${sleepMinutes},
timeRemaining: ${timeRemaining},
videoUrl: ${videoUrl}
    ''';
  }
}

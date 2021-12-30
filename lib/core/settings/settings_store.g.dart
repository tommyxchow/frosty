// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SettingsStore on _SettingsStoreBase, Store {
  final _$videoEnabledAtom = Atom(name: '_SettingsStoreBase.videoEnabled');

  @override
  bool get videoEnabled {
    _$videoEnabledAtom.reportRead();
    return super.videoEnabled;
  }

  @override
  set videoEnabled(bool value) {
    _$videoEnabledAtom.reportWrite(value, super.videoEnabled, () {
      super.videoEnabled = value;
    });
  }

  final _$overlayEnabledAtom = Atom(name: '_SettingsStoreBase.overlayEnabled');

  @override
  bool get overlayEnabled {
    _$overlayEnabledAtom.reportRead();
    return super.overlayEnabled;
  }

  @override
  set overlayEnabled(bool value) {
    _$overlayEnabledAtom.reportWrite(value, super.overlayEnabled, () {
      super.overlayEnabled = value;
    });
  }

  final _$hideBannedMessagesAtom =
      Atom(name: '_SettingsStoreBase.hideBannedMessages');

  @override
  bool get hideBannedMessages {
    _$hideBannedMessagesAtom.reportRead();
    return super.hideBannedMessages;
  }

  @override
  set hideBannedMessages(bool value) {
    _$hideBannedMessagesAtom.reportWrite(value, super.hideBannedMessages, () {
      super.hideBannedMessages = value;
    });
  }

  final _$zeroWidthEnabledAtom =
      Atom(name: '_SettingsStoreBase.zeroWidthEnabled');

  @override
  bool get zeroWidthEnabled {
    _$zeroWidthEnabledAtom.reportRead();
    return super.zeroWidthEnabled;
  }

  @override
  set zeroWidthEnabled(bool value) {
    _$zeroWidthEnabledAtom.reportWrite(value, super.zeroWidthEnabled, () {
      super.zeroWidthEnabled = value;
    });
  }

  final _$fullScreenAtom = Atom(name: '_SettingsStoreBase.fullScreen');

  @override
  bool get fullScreen {
    _$fullScreenAtom.reportRead();
    return super.fullScreen;
  }

  @override
  set fullScreen(bool value) {
    _$fullScreenAtom.reportWrite(value, super.fullScreen, () {
      super.fullScreen = value;
    });
  }

  final _$expandInfoAtom = Atom(name: '_SettingsStoreBase.expandInfo');

  @override
  bool get expandInfo {
    _$expandInfoAtom.reportRead();
    return super.expandInfo;
  }

  @override
  set expandInfo(bool value) {
    _$expandInfoAtom.reportWrite(value, super.expandInfo, () {
      super.expandInfo = value;
    });
  }

  final _$timeStampsEnabledAtom =
      Atom(name: '_SettingsStoreBase.timeStampsEnabled');

  @override
  bool get timeStampsEnabled {
    _$timeStampsEnabledAtom.reportRead();
    return super.timeStampsEnabled;
  }

  @override
  set timeStampsEnabled(bool value) {
    _$timeStampsEnabledAtom.reportWrite(value, super.timeStampsEnabled, () {
      super.timeStampsEnabled = value;
    });
  }

  final _$twelveHourTimeStampAtom =
      Atom(name: '_SettingsStoreBase.twelveHourTimeStamp');

  @override
  bool get twelveHourTimeStamp {
    _$twelveHourTimeStampAtom.reportRead();
    return super.twelveHourTimeStamp;
  }

  @override
  set twelveHourTimeStamp(bool value) {
    _$twelveHourTimeStampAtom.reportWrite(value, super.twelveHourTimeStamp, () {
      super.twelveHourTimeStamp = value;
    });
  }

  @override
  String toString() {
    return '''
videoEnabled: ${videoEnabled},
overlayEnabled: ${overlayEnabled},
hideBannedMessages: ${hideBannedMessages},
zeroWidthEnabled: ${zeroWidthEnabled},
fullScreen: ${fullScreen},
expandInfo: ${expandInfo},
timeStampsEnabled: ${timeStampsEnabled},
twelveHourTimeStamp: ${twelveHourTimeStamp}
    ''';
  }
}

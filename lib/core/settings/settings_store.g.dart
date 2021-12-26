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

  final _$messageLimitAtom = Atom(name: '_SettingsStoreBase.messageLimit');

  @override
  double get messageLimit {
    _$messageLimitAtom.reportRead();
    return super.messageLimit;
  }

  @override
  set messageLimit(double value) {
    _$messageLimitAtom.reportWrite(value, super.messageLimit, () {
      super.messageLimit = value;
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

  @override
  String toString() {
    return '''
videoEnabled: ${videoEnabled},
overlayEnabled: ${overlayEnabled},
messageLimit: ${messageLimit},
hideBannedMessages: ${hideBannedMessages},
zeroWidthEnabled: ${zeroWidthEnabled},
fullScreen: ${fullScreen}
    ''';
  }
}

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

  @override
  String toString() {
    return '''
videoEnabled: ${videoEnabled},
messageLimit: ${messageLimit},
hideBannedMessages: ${hideBannedMessages}
    ''';
  }
}

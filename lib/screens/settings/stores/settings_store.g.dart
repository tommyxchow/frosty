// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsStore _$SettingsStoreFromJson(Map<String, dynamic> json) => SettingsStore()
  ..useOledTheme = json['useOledTheme'] as bool
  ..showVideo = json['showVideo'] as bool
  ..showOverlay = json['showOverlay'] as bool
  ..showThumbnailUptime = json['showThumbnailUptime'] as bool
  ..useReadableColors = json['useReadableColors'] as bool
  ..showDeletedMessages = json['hideBannedMessages'] as bool
  ..showZeroWidth = json['showZeroWidth'] as bool
  ..showTimestamps = json['showTimestamps'] as bool
  ..useTwelveHourTimestamps = json['useTwelveHourTimestamps'] as bool
  ..fullScreen = json['fullScreen'] as bool
  ..expandInfo = json['expandInfo'] as bool;

Map<String, dynamic> _$SettingsStoreToJson(SettingsStore instance) => <String, dynamic>{
      'useOledTheme': instance.useOledTheme,
      'showVideo': instance.showVideo,
      'showOverlay': instance.showOverlay,
      'showThumbnailUptime': instance.showThumbnailUptime,
      'useReadableColors': instance.useReadableColors,
      'hideBannedMessages': instance.showDeletedMessages,
      'showZeroWidth': instance.showZeroWidth,
      'showTimestamps': instance.showTimestamps,
      'useTwelveHourTimestamps': instance.useTwelveHourTimestamps,
      'fullScreen': instance.fullScreen,
      'expandInfo': instance.expandInfo,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SettingsStore on _SettingsStoreBase, Store {
  final _$useOledThemeAtom = Atom(name: '_SettingsStoreBase.useOledTheme');

  @override
  bool get useOledTheme {
    _$useOledThemeAtom.reportRead();
    return super.useOledTheme;
  }

  @override
  set useOledTheme(bool value) {
    _$useOledThemeAtom.reportWrite(value, super.useOledTheme, () {
      super.useOledTheme = value;
    });
  }

  final _$showVideoAtom = Atom(name: '_SettingsStoreBase.showVideo');

  @override
  bool get showVideo {
    _$showVideoAtom.reportRead();
    return super.showVideo;
  }

  @override
  set showVideo(bool value) {
    _$showVideoAtom.reportWrite(value, super.showVideo, () {
      super.showVideo = value;
    });
  }

  final _$showOverlayAtom = Atom(name: '_SettingsStoreBase.showOverlay');

  @override
  bool get showOverlay {
    _$showOverlayAtom.reportRead();
    return super.showOverlay;
  }

  @override
  set showOverlay(bool value) {
    _$showOverlayAtom.reportWrite(value, super.showOverlay, () {
      super.showOverlay = value;
    });
  }

  final _$showThumbnailUptimeAtom = Atom(name: '_SettingsStoreBase.showThumbnailUptime');

  @override
  bool get showThumbnailUptime {
    _$showThumbnailUptimeAtom.reportRead();
    return super.showThumbnailUptime;
  }

  @override
  set showThumbnailUptime(bool value) {
    _$showThumbnailUptimeAtom.reportWrite(value, super.showThumbnailUptime, () {
      super.showThumbnailUptime = value;
    });
  }

  final _$useReadableColorsAtom = Atom(name: '_SettingsStoreBase.useReadableColors');

  @override
  bool get useReadableColors {
    _$useReadableColorsAtom.reportRead();
    return super.useReadableColors;
  }

  @override
  set useReadableColors(bool value) {
    _$useReadableColorsAtom.reportWrite(value, super.useReadableColors, () {
      super.useReadableColors = value;
    });
  }

  final _$hideBannedMessagesAtom = Atom(name: '_SettingsStoreBase.hideBannedMessages');

  @override
  bool get showDeletedMessages {
    _$hideBannedMessagesAtom.reportRead();
    return super.showDeletedMessages;
  }

  @override
  set showDeletedMessages(bool value) {
    _$hideBannedMessagesAtom.reportWrite(value, super.showDeletedMessages, () {
      super.showDeletedMessages = value;
    });
  }

  final _$showZeroWidthAtom = Atom(name: '_SettingsStoreBase.showZeroWidth');

  @override
  bool get showZeroWidth {
    _$showZeroWidthAtom.reportRead();
    return super.showZeroWidth;
  }

  @override
  set showZeroWidth(bool value) {
    _$showZeroWidthAtom.reportWrite(value, super.showZeroWidth, () {
      super.showZeroWidth = value;
    });
  }

  final _$showTimestampsAtom = Atom(name: '_SettingsStoreBase.showTimestamps');

  @override
  bool get showTimestamps {
    _$showTimestampsAtom.reportRead();
    return super.showTimestamps;
  }

  @override
  set showTimestamps(bool value) {
    _$showTimestampsAtom.reportWrite(value, super.showTimestamps, () {
      super.showTimestamps = value;
    });
  }

  final _$useTwelveHourTimestampsAtom = Atom(name: '_SettingsStoreBase.useTwelveHourTimestamps');

  @override
  bool get useTwelveHourTimestamps {
    _$useTwelveHourTimestampsAtom.reportRead();
    return super.useTwelveHourTimestamps;
  }

  @override
  set useTwelveHourTimestamps(bool value) {
    _$useTwelveHourTimestampsAtom.reportWrite(value, super.useTwelveHourTimestamps, () {
      super.useTwelveHourTimestamps = value;
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

  @override
  String toString() {
    return '''
useOledTheme: ${useOledTheme},
showVideo: ${showVideo},
showOverlay: ${showOverlay},
showThumbnailUptime: ${showThumbnailUptime},
useReadableColors: ${useReadableColors},
hideBannedMessages: ${showDeletedMessages},
showZeroWidth: ${showZeroWidth},
showTimestamps: ${showTimestamps},
useTwelveHourTimestamps: ${useTwelveHourTimestamps},
fullScreen: ${fullScreen},
expandInfo: ${expandInfo}
    ''';
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsStore _$SettingsStoreFromJson(Map<String, dynamic> json) =>
    SettingsStore()
      ..themeType = $enumDecodeNullable(_$ThemeTypeEnumMap, json['themeType'],
              unknownValue: ThemeType.system) ??
          ThemeType.system
      ..showThumbnailUptime = json['showThumbnailUptime'] as bool? ?? false
      ..showVideo = json['showVideo'] as bool? ?? true
      ..showOverlay = json['showOverlay'] as bool? ?? true
      ..toggleableOverlay = json['toggleableOverlay'] as bool? ?? false
      ..pictureInPicture = json['pictureInPicture'] as bool? ?? false
      ..showBottomBar = json['showBottomBar'] as bool? ?? true
      ..showDeletedMessages = json['showDeletedMessages'] as bool? ?? false
      ..showZeroWidth = json['showZeroWidth'] as bool? ?? false
      ..showChatMessageDividers =
          json['showChatMessageDividers'] as bool? ?? false
      ..timestampType = $enumDecodeNullable(
              _$TimestampTypeEnumMap, json['timestampType'],
              unknownValue: TimestampType.disabled) ??
          TimestampType.disabled
      ..useReadableColors = json['useReadableColors'] as bool? ?? true
      ..messageScale = (json['messageScale'] as num?)?.toDouble() ?? 1.0
      ..fontSize = (json['fontSize'] as num?)?.toDouble() ?? 14.0
      ..messageSpacing = (json['messageSpacing'] as num?)?.toDouble() ?? 10.0
      ..badgeScale = (json['badgeScale'] as num?)?.toDouble() ?? 1.0
      ..emoteScale = (json['emoteScale'] as num?)?.toDouble() ?? 1.0
      ..sendCrashLogs = json['sendCrashLogs'] as bool? ?? true
      ..fullScreen = json['fullScreen'] as bool? ?? false
      ..expandInfo = json['expandInfo'] as bool? ?? true;

Map<String, dynamic> _$SettingsStoreToJson(SettingsStore instance) =>
    <String, dynamic>{
      'themeType': _$ThemeTypeEnumMap[instance.themeType],
      'showThumbnailUptime': instance.showThumbnailUptime,
      'showVideo': instance.showVideo,
      'showOverlay': instance.showOverlay,
      'toggleableOverlay': instance.toggleableOverlay,
      'pictureInPicture': instance.pictureInPicture,
      'showBottomBar': instance.showBottomBar,
      'showDeletedMessages': instance.showDeletedMessages,
      'showZeroWidth': instance.showZeroWidth,
      'showChatMessageDividers': instance.showChatMessageDividers,
      'timestampType': _$TimestampTypeEnumMap[instance.timestampType],
      'useReadableColors': instance.useReadableColors,
      'messageScale': instance.messageScale,
      'fontSize': instance.fontSize,
      'messageSpacing': instance.messageSpacing,
      'badgeScale': instance.badgeScale,
      'emoteScale': instance.emoteScale,
      'sendCrashLogs': instance.sendCrashLogs,
      'fullScreen': instance.fullScreen,
      'expandInfo': instance.expandInfo,
    };

const _$ThemeTypeEnumMap = {
  ThemeType.system: 'system',
  ThemeType.light: 'light',
  ThemeType.dark: 'dark',
  ThemeType.black: 'black',
};

const _$TimestampTypeEnumMap = {
  TimestampType.disabled: 'disabled',
  TimestampType.twelve: 'twelve',
  TimestampType.twentyFour: 'twentyFour',
};

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SettingsStore on _SettingsStoreBase, Store {
  final _$themeTypeAtom = Atom(name: '_SettingsStoreBase.themeType');

  @override
  ThemeType get themeType {
    _$themeTypeAtom.reportRead();
    return super.themeType;
  }

  @override
  set themeType(ThemeType value) {
    _$themeTypeAtom.reportWrite(value, super.themeType, () {
      super.themeType = value;
    });
  }

  final _$showThumbnailUptimeAtom =
      Atom(name: '_SettingsStoreBase.showThumbnailUptime');

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

  final _$toggleableOverlayAtom =
      Atom(name: '_SettingsStoreBase.toggleableOverlay');

  @override
  bool get toggleableOverlay {
    _$toggleableOverlayAtom.reportRead();
    return super.toggleableOverlay;
  }

  @override
  set toggleableOverlay(bool value) {
    _$toggleableOverlayAtom.reportWrite(value, super.toggleableOverlay, () {
      super.toggleableOverlay = value;
    });
  }

  final _$pictureInPictureAtom =
      Atom(name: '_SettingsStoreBase.pictureInPicture');

  @override
  bool get pictureInPicture {
    _$pictureInPictureAtom.reportRead();
    return super.pictureInPicture;
  }

  @override
  set pictureInPicture(bool value) {
    _$pictureInPictureAtom.reportWrite(value, super.pictureInPicture, () {
      super.pictureInPicture = value;
    });
  }

  final _$showBottomBarAtom = Atom(name: '_SettingsStoreBase.showBottomBar');

  @override
  bool get showBottomBar {
    _$showBottomBarAtom.reportRead();
    return super.showBottomBar;
  }

  @override
  set showBottomBar(bool value) {
    _$showBottomBarAtom.reportWrite(value, super.showBottomBar, () {
      super.showBottomBar = value;
    });
  }

  final _$showDeletedMessagesAtom =
      Atom(name: '_SettingsStoreBase.showDeletedMessages');

  @override
  bool get showDeletedMessages {
    _$showDeletedMessagesAtom.reportRead();
    return super.showDeletedMessages;
  }

  @override
  set showDeletedMessages(bool value) {
    _$showDeletedMessagesAtom.reportWrite(value, super.showDeletedMessages, () {
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

  final _$showChatMessageDividersAtom =
      Atom(name: '_SettingsStoreBase.showChatMessageDividers');

  @override
  bool get showChatMessageDividers {
    _$showChatMessageDividersAtom.reportRead();
    return super.showChatMessageDividers;
  }

  @override
  set showChatMessageDividers(bool value) {
    _$showChatMessageDividersAtom
        .reportWrite(value, super.showChatMessageDividers, () {
      super.showChatMessageDividers = value;
    });
  }

  final _$timestampTypeAtom = Atom(name: '_SettingsStoreBase.timestampType');

  @override
  TimestampType get timestampType {
    _$timestampTypeAtom.reportRead();
    return super.timestampType;
  }

  @override
  set timestampType(TimestampType value) {
    _$timestampTypeAtom.reportWrite(value, super.timestampType, () {
      super.timestampType = value;
    });
  }

  final _$useReadableColorsAtom =
      Atom(name: '_SettingsStoreBase.useReadableColors');

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

  final _$messageScaleAtom = Atom(name: '_SettingsStoreBase.messageScale');

  @override
  double get messageScale {
    _$messageScaleAtom.reportRead();
    return super.messageScale;
  }

  @override
  set messageScale(double value) {
    _$messageScaleAtom.reportWrite(value, super.messageScale, () {
      super.messageScale = value;
    });
  }

  final _$fontSizeAtom = Atom(name: '_SettingsStoreBase.fontSize');

  @override
  double get fontSize {
    _$fontSizeAtom.reportRead();
    return super.fontSize;
  }

  @override
  set fontSize(double value) {
    _$fontSizeAtom.reportWrite(value, super.fontSize, () {
      super.fontSize = value;
    });
  }

  final _$messageSpacingAtom = Atom(name: '_SettingsStoreBase.messageSpacing');

  @override
  double get messageSpacing {
    _$messageSpacingAtom.reportRead();
    return super.messageSpacing;
  }

  @override
  set messageSpacing(double value) {
    _$messageSpacingAtom.reportWrite(value, super.messageSpacing, () {
      super.messageSpacing = value;
    });
  }

  final _$badgeScaleAtom = Atom(name: '_SettingsStoreBase.badgeScale');

  @override
  double get badgeScale {
    _$badgeScaleAtom.reportRead();
    return super.badgeScale;
  }

  @override
  set badgeScale(double value) {
    _$badgeScaleAtom.reportWrite(value, super.badgeScale, () {
      super.badgeScale = value;
    });
  }

  final _$emoteScaleAtom = Atom(name: '_SettingsStoreBase.emoteScale');

  @override
  double get emoteScale {
    _$emoteScaleAtom.reportRead();
    return super.emoteScale;
  }

  @override
  set emoteScale(double value) {
    _$emoteScaleAtom.reportWrite(value, super.emoteScale, () {
      super.emoteScale = value;
    });
  }

  final _$sendCrashLogsAtom = Atom(name: '_SettingsStoreBase.sendCrashLogs');

  @override
  bool get sendCrashLogs {
    _$sendCrashLogsAtom.reportRead();
    return super.sendCrashLogs;
  }

  @override
  set sendCrashLogs(bool value) {
    _$sendCrashLogsAtom.reportWrite(value, super.sendCrashLogs, () {
      super.sendCrashLogs = value;
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
themeType: ${themeType},
showThumbnailUptime: ${showThumbnailUptime},
showVideo: ${showVideo},
showOverlay: ${showOverlay},
toggleableOverlay: ${toggleableOverlay},
pictureInPicture: ${pictureInPicture},
showBottomBar: ${showBottomBar},
showDeletedMessages: ${showDeletedMessages},
showZeroWidth: ${showZeroWidth},
showChatMessageDividers: ${showChatMessageDividers},
timestampType: ${timestampType},
useReadableColors: ${useReadableColors},
messageScale: ${messageScale},
fontSize: ${fontSize},
messageSpacing: ${messageSpacing},
badgeScale: ${badgeScale},
emoteScale: ${emoteScale},
sendCrashLogs: ${sendCrashLogs},
fullScreen: ${fullScreen},
expandInfo: ${expandInfo}
    ''';
  }
}

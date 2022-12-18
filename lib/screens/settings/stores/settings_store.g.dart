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
      ..showThumbnails = json['showThumbnails'] as bool? ?? true
      ..largeStreamCard = json['largeStreamCard'] as bool? ?? false
      ..showThumbnailUptime = json['showThumbnailUptime'] as bool? ?? false
      ..launchUrlExternal = json['launchUrlExternal'] as bool? ?? false
      ..showVideo = json['showVideo'] as bool? ?? true
      ..showOverlay = json['showOverlay'] as bool? ?? true
      ..toggleableOverlay = json['toggleableOverlay'] as bool? ?? false
      ..automaticPip = json['automaticPip'] as bool? ?? false
      ..overlayOpacity = (json['overlayOpacity'] as num?)?.toDouble() ?? 0.5
      ..chatDelay = (json['chatDelay'] as num?)?.toDouble() ?? 0.0
      ..chatOnlyPreventSleep = json['chatOnlyPreventSleep'] as bool? ?? true
      ..autocomplete = json['autocomplete'] as bool? ?? true
      ..showBottomBar = json['showBottomBar'] as bool? ?? true
      ..emoteMenuButtonOnLeft = json['emoteMenuButtonOnLeft'] as bool? ?? false
      ..landscapeChatLeftSide = json['landscapeChatLeftSide'] as bool? ?? false
      ..landscapeForceVerticalChat =
          json['landscapeForceVerticalChat'] as bool? ?? false
      ..chatNotificationsOnBottom =
          json['chatNotificationsOnBottom'] as bool? ?? false
      ..landscapeCutout = $enumDecodeNullable(
              _$LandscapeCutoutTypeEnumMap, json['landscapeCutout']) ??
          LandscapeCutoutType.none
      ..chatWidth = (json['chatWidth'] as num?)?.toDouble() ?? 0.3
      ..fullScreenChatOverlayOpacity =
          (json['fullScreenChatOverlayOpacity'] as num?)?.toDouble() ?? 0.5
      ..useReadableColors = json['useReadableColors'] as bool? ?? true
      ..showDeletedMessages = json['showDeletedMessages'] as bool? ?? false
      ..showChatMessageDividers =
          json['showChatMessageDividers'] as bool? ?? false
      ..timestampType = $enumDecodeNullable(
              _$TimestampTypeEnumMap, json['timestampType'],
              unknownValue: TimestampType.disabled) ??
          TimestampType.disabled
      ..highlightFirstTimeChatter =
          json['highlightFirstTimeChatter'] as bool? ?? true
      ..showUserNotices = json['showUserNotices'] as bool? ?? true
      ..badgeScale = (json['badgeScale'] as num?)?.toDouble() ?? 1.0
      ..emoteScale = (json['emoteScale'] as num?)?.toDouble() ?? 1.0
      ..messageScale = (json['messageScale'] as num?)?.toDouble() ?? 1.0
      ..messageSpacing = (json['messageSpacing'] as num?)?.toDouble() ?? 10.0
      ..fontSize = (json['fontSize'] as num?)?.toDouble() ?? 12.0
      ..sendCrashLogs = json['sendCrashLogs'] as bool? ?? true
      ..fullScreen = json['fullScreen'] as bool? ?? false
      ..expandInfo = json['expandInfo'] as bool? ?? true
      ..fullScreenChatOverlay = json['fullScreenChatOverlay'] as bool? ?? false;

Map<String, dynamic> _$SettingsStoreToJson(SettingsStore instance) =>
    <String, dynamic>{
      'themeType': _$ThemeTypeEnumMap[instance.themeType]!,
      'showThumbnails': instance.showThumbnails,
      'largeStreamCard': instance.largeStreamCard,
      'showThumbnailUptime': instance.showThumbnailUptime,
      'launchUrlExternal': instance.launchUrlExternal,
      'showVideo': instance.showVideo,
      'showOverlay': instance.showOverlay,
      'toggleableOverlay': instance.toggleableOverlay,
      'automaticPip': instance.automaticPip,
      'overlayOpacity': instance.overlayOpacity,
      'chatDelay': instance.chatDelay,
      'chatOnlyPreventSleep': instance.chatOnlyPreventSleep,
      'autocomplete': instance.autocomplete,
      'showBottomBar': instance.showBottomBar,
      'emoteMenuButtonOnLeft': instance.emoteMenuButtonOnLeft,
      'landscapeChatLeftSide': instance.landscapeChatLeftSide,
      'landscapeForceVerticalChat': instance.landscapeForceVerticalChat,
      'chatNotificationsOnBottom': instance.chatNotificationsOnBottom,
      'landscapeCutout':
          _$LandscapeCutoutTypeEnumMap[instance.landscapeCutout]!,
      'chatWidth': instance.chatWidth,
      'fullScreenChatOverlayOpacity': instance.fullScreenChatOverlayOpacity,
      'useReadableColors': instance.useReadableColors,
      'showDeletedMessages': instance.showDeletedMessages,
      'showChatMessageDividers': instance.showChatMessageDividers,
      'timestampType': _$TimestampTypeEnumMap[instance.timestampType]!,
      'highlightFirstTimeChatter': instance.highlightFirstTimeChatter,
      'showUserNotices': instance.showUserNotices,
      'badgeScale': instance.badgeScale,
      'emoteScale': instance.emoteScale,
      'messageScale': instance.messageScale,
      'messageSpacing': instance.messageSpacing,
      'fontSize': instance.fontSize,
      'sendCrashLogs': instance.sendCrashLogs,
      'fullScreen': instance.fullScreen,
      'expandInfo': instance.expandInfo,
      'fullScreenChatOverlay': instance.fullScreenChatOverlay,
    };

const _$ThemeTypeEnumMap = {
  ThemeType.system: 'system',
  ThemeType.light: 'light',
  ThemeType.dark: 'dark',
  ThemeType.black: 'black',
};

const _$LandscapeCutoutTypeEnumMap = {
  LandscapeCutoutType.none: 'none',
  LandscapeCutoutType.left: 'left',
  LandscapeCutoutType.right: 'right',
  LandscapeCutoutType.both: 'both',
};

const _$TimestampTypeEnumMap = {
  TimestampType.disabled: 'disabled',
  TimestampType.twelve: 'twelve',
  TimestampType.twentyFour: 'twentyFour',
};

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStoreBase, Store {
  late final _$themeTypeAtom =
      Atom(name: '_SettingsStoreBase.themeType', context: context);

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

  late final _$showThumbnailsAtom =
      Atom(name: '_SettingsStoreBase.showThumbnails', context: context);

  @override
  bool get showThumbnails {
    _$showThumbnailsAtom.reportRead();
    return super.showThumbnails;
  }

  @override
  set showThumbnails(bool value) {
    _$showThumbnailsAtom.reportWrite(value, super.showThumbnails, () {
      super.showThumbnails = value;
    });
  }

  late final _$largeStreamCardAtom =
      Atom(name: '_SettingsStoreBase.largeStreamCard', context: context);

  @override
  bool get largeStreamCard {
    _$largeStreamCardAtom.reportRead();
    return super.largeStreamCard;
  }

  @override
  set largeStreamCard(bool value) {
    _$largeStreamCardAtom.reportWrite(value, super.largeStreamCard, () {
      super.largeStreamCard = value;
    });
  }

  late final _$showThumbnailUptimeAtom =
      Atom(name: '_SettingsStoreBase.showThumbnailUptime', context: context);

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

  late final _$launchUrlExternalAtom =
      Atom(name: '_SettingsStoreBase.launchUrlExternal', context: context);

  @override
  bool get launchUrlExternal {
    _$launchUrlExternalAtom.reportRead();
    return super.launchUrlExternal;
  }

  @override
  set launchUrlExternal(bool value) {
    _$launchUrlExternalAtom.reportWrite(value, super.launchUrlExternal, () {
      super.launchUrlExternal = value;
    });
  }

  late final _$showVideoAtom =
      Atom(name: '_SettingsStoreBase.showVideo', context: context);

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

  late final _$showOverlayAtom =
      Atom(name: '_SettingsStoreBase.showOverlay', context: context);

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

  late final _$toggleableOverlayAtom =
      Atom(name: '_SettingsStoreBase.toggleableOverlay', context: context);

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

  late final _$automaticPipAtom =
      Atom(name: '_SettingsStoreBase.automaticPip', context: context);

  @override
  bool get automaticPip {
    _$automaticPipAtom.reportRead();
    return super.automaticPip;
  }

  @override
  set automaticPip(bool value) {
    _$automaticPipAtom.reportWrite(value, super.automaticPip, () {
      super.automaticPip = value;
    });
  }

  late final _$overlayOpacityAtom =
      Atom(name: '_SettingsStoreBase.overlayOpacity', context: context);

  @override
  double get overlayOpacity {
    _$overlayOpacityAtom.reportRead();
    return super.overlayOpacity;
  }

  @override
  set overlayOpacity(double value) {
    _$overlayOpacityAtom.reportWrite(value, super.overlayOpacity, () {
      super.overlayOpacity = value;
    });
  }

  late final _$chatDelayAtom =
      Atom(name: '_SettingsStoreBase.chatDelay', context: context);

  @override
  double get chatDelay {
    _$chatDelayAtom.reportRead();
    return super.chatDelay;
  }

  @override
  set chatDelay(double value) {
    _$chatDelayAtom.reportWrite(value, super.chatDelay, () {
      super.chatDelay = value;
    });
  }

  late final _$chatOnlyPreventSleepAtom =
      Atom(name: '_SettingsStoreBase.chatOnlyPreventSleep', context: context);

  @override
  bool get chatOnlyPreventSleep {
    _$chatOnlyPreventSleepAtom.reportRead();
    return super.chatOnlyPreventSleep;
  }

  @override
  set chatOnlyPreventSleep(bool value) {
    _$chatOnlyPreventSleepAtom.reportWrite(value, super.chatOnlyPreventSleep,
        () {
      super.chatOnlyPreventSleep = value;
    });
  }

  late final _$autocompleteAtom =
      Atom(name: '_SettingsStoreBase.autocomplete', context: context);

  @override
  bool get autocomplete {
    _$autocompleteAtom.reportRead();
    return super.autocomplete;
  }

  @override
  set autocomplete(bool value) {
    _$autocompleteAtom.reportWrite(value, super.autocomplete, () {
      super.autocomplete = value;
    });
  }

  late final _$showBottomBarAtom =
      Atom(name: '_SettingsStoreBase.showBottomBar', context: context);

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

  late final _$emoteMenuButtonOnLeftAtom =
      Atom(name: '_SettingsStoreBase.emoteMenuButtonOnLeft', context: context);

  @override
  bool get emoteMenuButtonOnLeft {
    _$emoteMenuButtonOnLeftAtom.reportRead();
    return super.emoteMenuButtonOnLeft;
  }

  @override
  set emoteMenuButtonOnLeft(bool value) {
    _$emoteMenuButtonOnLeftAtom.reportWrite(value, super.emoteMenuButtonOnLeft,
        () {
      super.emoteMenuButtonOnLeft = value;
    });
  }

  late final _$landscapeChatLeftSideAtom =
      Atom(name: '_SettingsStoreBase.landscapeChatLeftSide', context: context);

  @override
  bool get landscapeChatLeftSide {
    _$landscapeChatLeftSideAtom.reportRead();
    return super.landscapeChatLeftSide;
  }

  @override
  set landscapeChatLeftSide(bool value) {
    _$landscapeChatLeftSideAtom.reportWrite(value, super.landscapeChatLeftSide,
        () {
      super.landscapeChatLeftSide = value;
    });
  }

  late final _$landscapeForceVerticalChatAtom = Atom(
      name: '_SettingsStoreBase.landscapeForceVerticalChat', context: context);

  @override
  bool get landscapeForceVerticalChat {
    _$landscapeForceVerticalChatAtom.reportRead();
    return super.landscapeForceVerticalChat;
  }

  @override
  set landscapeForceVerticalChat(bool value) {
    _$landscapeForceVerticalChatAtom
        .reportWrite(value, super.landscapeForceVerticalChat, () {
      super.landscapeForceVerticalChat = value;
    });
  }

  late final _$chatNotificationsOnBottomAtom = Atom(
      name: '_SettingsStoreBase.chatNotificationsOnBottom', context: context);

  @override
  bool get chatNotificationsOnBottom {
    _$chatNotificationsOnBottomAtom.reportRead();
    return super.chatNotificationsOnBottom;
  }

  @override
  set chatNotificationsOnBottom(bool value) {
    _$chatNotificationsOnBottomAtom
        .reportWrite(value, super.chatNotificationsOnBottom, () {
      super.chatNotificationsOnBottom = value;
    });
  }

  late final _$landscapeCutoutAtom =
      Atom(name: '_SettingsStoreBase.landscapeCutout', context: context);

  @override
  LandscapeCutoutType get landscapeCutout {
    _$landscapeCutoutAtom.reportRead();
    return super.landscapeCutout;
  }

  @override
  set landscapeCutout(LandscapeCutoutType value) {
    _$landscapeCutoutAtom.reportWrite(value, super.landscapeCutout, () {
      super.landscapeCutout = value;
    });
  }

  late final _$chatWidthAtom =
      Atom(name: '_SettingsStoreBase.chatWidth', context: context);

  @override
  double get chatWidth {
    _$chatWidthAtom.reportRead();
    return super.chatWidth;
  }

  @override
  set chatWidth(double value) {
    _$chatWidthAtom.reportWrite(value, super.chatWidth, () {
      super.chatWidth = value;
    });
  }

  late final _$fullScreenChatOverlayOpacityAtom = Atom(
      name: '_SettingsStoreBase.fullScreenChatOverlayOpacity',
      context: context);

  @override
  double get fullScreenChatOverlayOpacity {
    _$fullScreenChatOverlayOpacityAtom.reportRead();
    return super.fullScreenChatOverlayOpacity;
  }

  @override
  set fullScreenChatOverlayOpacity(double value) {
    _$fullScreenChatOverlayOpacityAtom
        .reportWrite(value, super.fullScreenChatOverlayOpacity, () {
      super.fullScreenChatOverlayOpacity = value;
    });
  }

  late final _$useReadableColorsAtom =
      Atom(name: '_SettingsStoreBase.useReadableColors', context: context);

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

  late final _$showDeletedMessagesAtom =
      Atom(name: '_SettingsStoreBase.showDeletedMessages', context: context);

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

  late final _$showChatMessageDividersAtom = Atom(
      name: '_SettingsStoreBase.showChatMessageDividers', context: context);

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

  late final _$timestampTypeAtom =
      Atom(name: '_SettingsStoreBase.timestampType', context: context);

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

  late final _$highlightFirstTimeChatterAtom = Atom(
      name: '_SettingsStoreBase.highlightFirstTimeChatter', context: context);

  @override
  bool get highlightFirstTimeChatter {
    _$highlightFirstTimeChatterAtom.reportRead();
    return super.highlightFirstTimeChatter;
  }

  @override
  set highlightFirstTimeChatter(bool value) {
    _$highlightFirstTimeChatterAtom
        .reportWrite(value, super.highlightFirstTimeChatter, () {
      super.highlightFirstTimeChatter = value;
    });
  }

  late final _$showUserNoticesAtom =
      Atom(name: '_SettingsStoreBase.showUserNotices', context: context);

  @override
  bool get showUserNotices {
    _$showUserNoticesAtom.reportRead();
    return super.showUserNotices;
  }

  @override
  set showUserNotices(bool value) {
    _$showUserNoticesAtom.reportWrite(value, super.showUserNotices, () {
      super.showUserNotices = value;
    });
  }

  late final _$badgeScaleAtom =
      Atom(name: '_SettingsStoreBase.badgeScale', context: context);

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

  late final _$emoteScaleAtom =
      Atom(name: '_SettingsStoreBase.emoteScale', context: context);

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

  late final _$messageScaleAtom =
      Atom(name: '_SettingsStoreBase.messageScale', context: context);

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

  late final _$messageSpacingAtom =
      Atom(name: '_SettingsStoreBase.messageSpacing', context: context);

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

  late final _$fontSizeAtom =
      Atom(name: '_SettingsStoreBase.fontSize', context: context);

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

  late final _$sendCrashLogsAtom =
      Atom(name: '_SettingsStoreBase.sendCrashLogs', context: context);

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

  late final _$fullScreenAtom =
      Atom(name: '_SettingsStoreBase.fullScreen', context: context);

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

  late final _$expandInfoAtom =
      Atom(name: '_SettingsStoreBase.expandInfo', context: context);

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

  late final _$fullScreenChatOverlayAtom =
      Atom(name: '_SettingsStoreBase.fullScreenChatOverlay', context: context);

  @override
  bool get fullScreenChatOverlay {
    _$fullScreenChatOverlayAtom.reportRead();
    return super.fullScreenChatOverlay;
  }

  @override
  set fullScreenChatOverlay(bool value) {
    _$fullScreenChatOverlayAtom.reportWrite(value, super.fullScreenChatOverlay,
        () {
      super.fullScreenChatOverlay = value;
    });
  }

  late final _$_SettingsStoreBaseActionController =
      ActionController(name: '_SettingsStoreBase', context: context);

  @override
  void resetGeneralSettings() {
    final _$actionInfo = _$_SettingsStoreBaseActionController.startAction(
        name: '_SettingsStoreBase.resetGeneralSettings');
    try {
      return super.resetGeneralSettings();
    } finally {
      _$_SettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetVideoSettings() {
    final _$actionInfo = _$_SettingsStoreBaseActionController.startAction(
        name: '_SettingsStoreBase.resetVideoSettings');
    try {
      return super.resetVideoSettings();
    } finally {
      _$_SettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetChatSettings() {
    final _$actionInfo = _$_SettingsStoreBaseActionController.startAction(
        name: '_SettingsStoreBase.resetChatSettings');
    try {
      return super.resetChatSettings();
    } finally {
      _$_SettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetOtherSettings() {
    final _$actionInfo = _$_SettingsStoreBaseActionController.startAction(
        name: '_SettingsStoreBase.resetOtherSettings');
    try {
      return super.resetOtherSettings();
    } finally {
      _$_SettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetGlobalConfigs() {
    final _$actionInfo = _$_SettingsStoreBaseActionController.startAction(
        name: '_SettingsStoreBase.resetGlobalConfigs');
    try {
      return super.resetGlobalConfigs();
    } finally {
      _$_SettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetAllSettings() {
    final _$actionInfo = _$_SettingsStoreBaseActionController.startAction(
        name: '_SettingsStoreBase.resetAllSettings');
    try {
      return super.resetAllSettings();
    } finally {
      _$_SettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
themeType: ${themeType},
showThumbnails: ${showThumbnails},
largeStreamCard: ${largeStreamCard},
showThumbnailUptime: ${showThumbnailUptime},
launchUrlExternal: ${launchUrlExternal},
showVideo: ${showVideo},
showOverlay: ${showOverlay},
toggleableOverlay: ${toggleableOverlay},
automaticPip: ${automaticPip},
overlayOpacity: ${overlayOpacity},
chatDelay: ${chatDelay},
chatOnlyPreventSleep: ${chatOnlyPreventSleep},
autocomplete: ${autocomplete},
showBottomBar: ${showBottomBar},
emoteMenuButtonOnLeft: ${emoteMenuButtonOnLeft},
landscapeChatLeftSide: ${landscapeChatLeftSide},
landscapeForceVerticalChat: ${landscapeForceVerticalChat},
chatNotificationsOnBottom: ${chatNotificationsOnBottom},
landscapeCutout: ${landscapeCutout},
chatWidth: ${chatWidth},
fullScreenChatOverlayOpacity: ${fullScreenChatOverlayOpacity},
useReadableColors: ${useReadableColors},
showDeletedMessages: ${showDeletedMessages},
showChatMessageDividers: ${showChatMessageDividers},
timestampType: ${timestampType},
highlightFirstTimeChatter: ${highlightFirstTimeChatter},
showUserNotices: ${showUserNotices},
badgeScale: ${badgeScale},
emoteScale: ${emoteScale},
messageScale: ${messageScale},
messageSpacing: ${messageSpacing},
fontSize: ${fontSize},
sendCrashLogs: ${sendCrashLogs},
fullScreen: ${fullScreen},
expandInfo: ${expandInfo},
fullScreenChatOverlay: ${fullScreenChatOverlay}
    ''';
  }
}

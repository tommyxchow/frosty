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
      ..accentColor = (json['accentColor'] as num?)?.toInt() ?? 4287710975
      ..showThumbnails = json['showThumbnails'] as bool? ?? true
      ..largeStreamCard = json['largeStreamCard'] as bool? ?? false
      ..launchUrlExternal = json['launchUrlExternal'] as bool? ?? false
      ..showVideo = json['showVideo'] as bool? ?? true
      ..defaultToHighestQuality =
          json['defaultToHighestQuality'] as bool? ?? false
      ..showLatency = json['showLatency'] as bool? ?? true
      ..useEnhancedRendering = json['useEnhancedRendering'] as bool? ?? false
      ..showOverlay = json['showOverlay'] as bool? ?? true
      ..toggleableOverlay = json['toggleableOverlay'] as bool? ?? false
      ..overlayOpacity = (json['overlayOpacity'] as num?)?.toDouble() ?? 0.5
      ..badgeScale = (json['badgeScale'] as num?)?.toDouble() ?? 1.0
      ..emoteScale = (json['emoteScale'] as num?)?.toDouble() ?? 1.0
      ..messageScale = (json['messageScale'] as num?)?.toDouble() ?? 1.0
      ..messageSpacing = (json['messageSpacing'] as num?)?.toDouble() ?? 8.0
      ..fontSize = (json['fontSize'] as num?)?.toDouble() ?? 12.0
      ..useReadableColors = json['useReadableColors'] as bool? ?? true
      ..showDeletedMessages = json['showDeletedMessages'] as bool? ?? false
      ..showChatMessageDividers =
          json['showChatMessageDividers'] as bool? ?? false
      ..timestampType = $enumDecodeNullable(
              _$TimestampTypeEnumMap, json['timestampType'],
              unknownValue: TimestampType.disabled) ??
          TimestampType.disabled
      ..autoSyncChatDelay = json['autoSyncChatDelay'] as bool? ?? false
      ..chatDelay = (json['chatDelay'] as num?)?.toDouble() ?? 0.0
      ..highlightFirstTimeChatter =
          json['highlightFirstTimeChatter'] as bool? ?? true
      ..showUserNotices = json['showUserNotices'] as bool? ?? true
      ..showBottomBar = json['showBottomBar'] as bool? ?? true
      ..emoteMenuButtonOnLeft = json['emoteMenuButtonOnLeft'] as bool? ?? false
      ..chatNotificationsOnBottom =
          json['chatNotificationsOnBottom'] as bool? ?? false
      ..landscapeChatLeftSide = json['landscapeChatLeftSide'] as bool? ?? false
      ..landscapeForceVerticalChat =
          json['landscapeForceVerticalChat'] as bool? ?? false
      ..landscapeCutout = $enumDecodeNullable(
              _$LandscapeCutoutTypeEnumMap, json['landscapeCutout']) ??
          LandscapeCutoutType.none
      ..chatWidth = (json['chatWidth'] as num?)?.toDouble() ?? 0.25
      ..fullScreenChatOverlayOpacity =
          (json['fullScreenChatOverlayOpacity'] as num?)?.toDouble() ?? 0.5
      ..chatOnlyPreventSleep = json['chatOnlyPreventSleep'] as bool? ?? false
      ..autocomplete = json['autocomplete'] as bool? ?? true
      ..showTwitchEmotes = json['showTwitchEmotes'] as bool? ?? true
      ..showTwitchBadges = json['showTwitchBadges'] as bool? ?? true
      ..show7TVEmotes = json['show7TVEmotes'] as bool? ?? true
      ..showBTTVEmotes = json['showBTTVEmotes'] as bool? ?? true
      ..showBTTVBadges = json['showBTTVBadges'] as bool? ?? true
      ..showFFZEmotes = json['showFFZEmotes'] as bool? ?? true
      ..showFFZBadges = json['showFFZBadges'] as bool? ?? true
      ..showRecentMessages = json['showRecentMessages'] as bool? ?? false
      ..mutedWords = (json['mutedWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          []
      ..matchWholeWord = json['matchWholeWord'] as bool? ?? true
      ..shareCrashLogsAndAnalytics =
          json['shareCrashLogsAndAnalytics'] as bool? ?? true
      ..fullScreen = json['fullScreen'] as bool? ?? false
      ..fullScreenChatOverlay = json['fullScreenChatOverlay'] as bool? ?? false
      ..pinnedChannelIds = (json['pinnedChannelIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];

Map<String, dynamic> _$SettingsStoreToJson(SettingsStore instance) =>
    <String, dynamic>{
      'themeType': _$ThemeTypeEnumMap[instance.themeType]!,
      'accentColor': instance.accentColor,
      'showThumbnails': instance.showThumbnails,
      'largeStreamCard': instance.largeStreamCard,
      'launchUrlExternal': instance.launchUrlExternal,
      'showVideo': instance.showVideo,
      'defaultToHighestQuality': instance.defaultToHighestQuality,
      'showLatency': instance.showLatency,
      'useEnhancedRendering': instance.useEnhancedRendering,
      'showOverlay': instance.showOverlay,
      'toggleableOverlay': instance.toggleableOverlay,
      'overlayOpacity': instance.overlayOpacity,
      'badgeScale': instance.badgeScale,
      'emoteScale': instance.emoteScale,
      'messageScale': instance.messageScale,
      'messageSpacing': instance.messageSpacing,
      'fontSize': instance.fontSize,
      'useReadableColors': instance.useReadableColors,
      'showDeletedMessages': instance.showDeletedMessages,
      'showChatMessageDividers': instance.showChatMessageDividers,
      'timestampType': _$TimestampTypeEnumMap[instance.timestampType]!,
      'autoSyncChatDelay': instance.autoSyncChatDelay,
      'chatDelay': instance.chatDelay,
      'highlightFirstTimeChatter': instance.highlightFirstTimeChatter,
      'showUserNotices': instance.showUserNotices,
      'showBottomBar': instance.showBottomBar,
      'emoteMenuButtonOnLeft': instance.emoteMenuButtonOnLeft,
      'chatNotificationsOnBottom': instance.chatNotificationsOnBottom,
      'landscapeChatLeftSide': instance.landscapeChatLeftSide,
      'landscapeForceVerticalChat': instance.landscapeForceVerticalChat,
      'landscapeCutout':
          _$LandscapeCutoutTypeEnumMap[instance.landscapeCutout]!,
      'chatWidth': instance.chatWidth,
      'fullScreenChatOverlayOpacity': instance.fullScreenChatOverlayOpacity,
      'chatOnlyPreventSleep': instance.chatOnlyPreventSleep,
      'autocomplete': instance.autocomplete,
      'showTwitchEmotes': instance.showTwitchEmotes,
      'showTwitchBadges': instance.showTwitchBadges,
      'show7TVEmotes': instance.show7TVEmotes,
      'showBTTVEmotes': instance.showBTTVEmotes,
      'showBTTVBadges': instance.showBTTVBadges,
      'showFFZEmotes': instance.showFFZEmotes,
      'showFFZBadges': instance.showFFZBadges,
      'showRecentMessages': instance.showRecentMessages,
      'mutedWords': instance.mutedWords,
      'matchWholeWord': instance.matchWholeWord,
      'shareCrashLogsAndAnalytics': instance.shareCrashLogsAndAnalytics,
      'fullScreen': instance.fullScreen,
      'fullScreenChatOverlay': instance.fullScreenChatOverlay,
      'pinnedChannelIds': instance.pinnedChannelIds,
    };

const _$ThemeTypeEnumMap = {
  ThemeType.system: 'system',
  ThemeType.light: 'light',
  ThemeType.dark: 'dark',
};

const _$TimestampTypeEnumMap = {
  TimestampType.disabled: 'disabled',
  TimestampType.twelve: 'twelve',
  TimestampType.twentyFour: 'twentyFour',
};

const _$LandscapeCutoutTypeEnumMap = {
  LandscapeCutoutType.none: 'none',
  LandscapeCutoutType.left: 'left',
  LandscapeCutoutType.right: 'right',
  LandscapeCutoutType.both: 'both',
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

  late final _$accentColorAtom =
      Atom(name: '_SettingsStoreBase.accentColor', context: context);

  @override
  int get accentColor {
    _$accentColorAtom.reportRead();
    return super.accentColor;
  }

  @override
  set accentColor(int value) {
    _$accentColorAtom.reportWrite(value, super.accentColor, () {
      super.accentColor = value;
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

  late final _$defaultToHighestQualityAtom = Atom(
      name: '_SettingsStoreBase.defaultToHighestQuality', context: context);

  @override
  bool get defaultToHighestQuality {
    _$defaultToHighestQualityAtom.reportRead();
    return super.defaultToHighestQuality;
  }

  @override
  set defaultToHighestQuality(bool value) {
    _$defaultToHighestQualityAtom
        .reportWrite(value, super.defaultToHighestQuality, () {
      super.defaultToHighestQuality = value;
    });
  }

  late final _$showLatencyAtom =
      Atom(name: '_SettingsStoreBase.showLatency', context: context);

  @override
  bool get showLatency {
    _$showLatencyAtom.reportRead();
    return super.showLatency;
  }

  @override
  set showLatency(bool value) {
    _$showLatencyAtom.reportWrite(value, super.showLatency, () {
      super.showLatency = value;
    });
  }

  late final _$useEnhancedRenderingAtom =
      Atom(name: '_SettingsStoreBase.useEnhancedRendering', context: context);

  @override
  bool get useEnhancedRendering {
    _$useEnhancedRenderingAtom.reportRead();
    return super.useEnhancedRendering;
  }

  @override
  set useEnhancedRendering(bool value) {
    _$useEnhancedRenderingAtom.reportWrite(value, super.useEnhancedRendering,
        () {
      super.useEnhancedRendering = value;
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

  late final _$autoSyncChatDelayAtom =
      Atom(name: '_SettingsStoreBase.autoSyncChatDelay', context: context);

  @override
  bool get autoSyncChatDelay {
    _$autoSyncChatDelayAtom.reportRead();
    return super.autoSyncChatDelay;
  }

  @override
  set autoSyncChatDelay(bool value) {
    _$autoSyncChatDelayAtom.reportWrite(value, super.autoSyncChatDelay, () {
      super.autoSyncChatDelay = value;
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

  late final _$showTwitchEmotesAtom =
      Atom(name: '_SettingsStoreBase.showTwitchEmotes', context: context);

  @override
  bool get showTwitchEmotes {
    _$showTwitchEmotesAtom.reportRead();
    return super.showTwitchEmotes;
  }

  @override
  set showTwitchEmotes(bool value) {
    _$showTwitchEmotesAtom.reportWrite(value, super.showTwitchEmotes, () {
      super.showTwitchEmotes = value;
    });
  }

  late final _$showTwitchBadgesAtom =
      Atom(name: '_SettingsStoreBase.showTwitchBadges', context: context);

  @override
  bool get showTwitchBadges {
    _$showTwitchBadgesAtom.reportRead();
    return super.showTwitchBadges;
  }

  @override
  set showTwitchBadges(bool value) {
    _$showTwitchBadgesAtom.reportWrite(value, super.showTwitchBadges, () {
      super.showTwitchBadges = value;
    });
  }

  late final _$show7TVEmotesAtom =
      Atom(name: '_SettingsStoreBase.show7TVEmotes', context: context);

  @override
  bool get show7TVEmotes {
    _$show7TVEmotesAtom.reportRead();
    return super.show7TVEmotes;
  }

  @override
  set show7TVEmotes(bool value) {
    _$show7TVEmotesAtom.reportWrite(value, super.show7TVEmotes, () {
      super.show7TVEmotes = value;
    });
  }

  late final _$showBTTVEmotesAtom =
      Atom(name: '_SettingsStoreBase.showBTTVEmotes', context: context);

  @override
  bool get showBTTVEmotes {
    _$showBTTVEmotesAtom.reportRead();
    return super.showBTTVEmotes;
  }

  @override
  set showBTTVEmotes(bool value) {
    _$showBTTVEmotesAtom.reportWrite(value, super.showBTTVEmotes, () {
      super.showBTTVEmotes = value;
    });
  }

  late final _$showBTTVBadgesAtom =
      Atom(name: '_SettingsStoreBase.showBTTVBadges', context: context);

  @override
  bool get showBTTVBadges {
    _$showBTTVBadgesAtom.reportRead();
    return super.showBTTVBadges;
  }

  @override
  set showBTTVBadges(bool value) {
    _$showBTTVBadgesAtom.reportWrite(value, super.showBTTVBadges, () {
      super.showBTTVBadges = value;
    });
  }

  late final _$showFFZEmotesAtom =
      Atom(name: '_SettingsStoreBase.showFFZEmotes', context: context);

  @override
  bool get showFFZEmotes {
    _$showFFZEmotesAtom.reportRead();
    return super.showFFZEmotes;
  }

  @override
  set showFFZEmotes(bool value) {
    _$showFFZEmotesAtom.reportWrite(value, super.showFFZEmotes, () {
      super.showFFZEmotes = value;
    });
  }

  late final _$showFFZBadgesAtom =
      Atom(name: '_SettingsStoreBase.showFFZBadges', context: context);

  @override
  bool get showFFZBadges {
    _$showFFZBadgesAtom.reportRead();
    return super.showFFZBadges;
  }

  @override
  set showFFZBadges(bool value) {
    _$showFFZBadgesAtom.reportWrite(value, super.showFFZBadges, () {
      super.showFFZBadges = value;
    });
  }

  late final _$showRecentMessagesAtom =
      Atom(name: '_SettingsStoreBase.showRecentMessages', context: context);

  @override
  bool get showRecentMessages {
    _$showRecentMessagesAtom.reportRead();
    return super.showRecentMessages;
  }

  @override
  set showRecentMessages(bool value) {
    _$showRecentMessagesAtom.reportWrite(value, super.showRecentMessages, () {
      super.showRecentMessages = value;
    });
  }

  late final _$mutedWordsAtom =
      Atom(name: '_SettingsStoreBase.mutedWords', context: context);

  @override
  List<String> get mutedWords {
    _$mutedWordsAtom.reportRead();
    return super.mutedWords;
  }

  @override
  set mutedWords(List<String> value) {
    _$mutedWordsAtom.reportWrite(value, super.mutedWords, () {
      super.mutedWords = value;
    });
  }

  late final _$matchWholeWordAtom =
      Atom(name: '_SettingsStoreBase.matchWholeWord', context: context);

  @override
  bool get matchWholeWord {
    _$matchWholeWordAtom.reportRead();
    return super.matchWholeWord;
  }

  @override
  set matchWholeWord(bool value) {
    _$matchWholeWordAtom.reportWrite(value, super.matchWholeWord, () {
      super.matchWholeWord = value;
    });
  }

  late final _$shareCrashLogsAndAnalyticsAtom = Atom(
      name: '_SettingsStoreBase.shareCrashLogsAndAnalytics', context: context);

  @override
  bool get shareCrashLogsAndAnalytics {
    _$shareCrashLogsAndAnalyticsAtom.reportRead();
    return super.shareCrashLogsAndAnalytics;
  }

  @override
  set shareCrashLogsAndAnalytics(bool value) {
    _$shareCrashLogsAndAnalyticsAtom
        .reportWrite(value, super.shareCrashLogsAndAnalytics, () {
      super.shareCrashLogsAndAnalytics = value;
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

  late final _$pinnedChannelIdsAtom =
      Atom(name: '_SettingsStoreBase.pinnedChannelIds', context: context);

  @override
  List<String> get pinnedChannelIds {
    _$pinnedChannelIdsAtom.reportRead();
    return super.pinnedChannelIds;
  }

  @override
  set pinnedChannelIds(List<String> value) {
    _$pinnedChannelIdsAtom.reportWrite(value, super.pinnedChannelIds, () {
      super.pinnedChannelIds = value;
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
accentColor: ${accentColor},
showThumbnails: ${showThumbnails},
largeStreamCard: ${largeStreamCard},
launchUrlExternal: ${launchUrlExternal},
showVideo: ${showVideo},
defaultToHighestQuality: ${defaultToHighestQuality},
showLatency: ${showLatency},
useEnhancedRendering: ${useEnhancedRendering},
showOverlay: ${showOverlay},
toggleableOverlay: ${toggleableOverlay},
overlayOpacity: ${overlayOpacity},
badgeScale: ${badgeScale},
emoteScale: ${emoteScale},
messageScale: ${messageScale},
messageSpacing: ${messageSpacing},
fontSize: ${fontSize},
useReadableColors: ${useReadableColors},
showDeletedMessages: ${showDeletedMessages},
showChatMessageDividers: ${showChatMessageDividers},
timestampType: ${timestampType},
autoSyncChatDelay: ${autoSyncChatDelay},
chatDelay: ${chatDelay},
highlightFirstTimeChatter: ${highlightFirstTimeChatter},
showUserNotices: ${showUserNotices},
showBottomBar: ${showBottomBar},
emoteMenuButtonOnLeft: ${emoteMenuButtonOnLeft},
chatNotificationsOnBottom: ${chatNotificationsOnBottom},
landscapeChatLeftSide: ${landscapeChatLeftSide},
landscapeForceVerticalChat: ${landscapeForceVerticalChat},
landscapeCutout: ${landscapeCutout},
chatWidth: ${chatWidth},
fullScreenChatOverlayOpacity: ${fullScreenChatOverlayOpacity},
chatOnlyPreventSleep: ${chatOnlyPreventSleep},
autocomplete: ${autocomplete},
showTwitchEmotes: ${showTwitchEmotes},
showTwitchBadges: ${showTwitchBadges},
show7TVEmotes: ${show7TVEmotes},
showBTTVEmotes: ${showBTTVEmotes},
showBTTVBadges: ${showBTTVBadges},
showFFZEmotes: ${showFFZEmotes},
showFFZBadges: ${showFFZBadges},
showRecentMessages: ${showRecentMessages},
mutedWords: ${mutedWords},
matchWholeWord: ${matchWholeWord},
shareCrashLogsAndAnalytics: ${shareCrashLogsAndAnalytics},
fullScreen: ${fullScreen},
fullScreenChatOverlay: ${fullScreenChatOverlay},
pinnedChannelIds: ${pinnedChannelIds}
    ''';
  }
}

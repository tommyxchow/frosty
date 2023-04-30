import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'settings_store.g.dart';

@JsonSerializable()
class SettingsStore extends _SettingsStoreBase with _$SettingsStore {
  SettingsStore();

  factory SettingsStore.fromJson(Map<String, dynamic> json) =>
      _$SettingsStoreFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsStoreToJson(this);
}

abstract class _SettingsStoreBase with Store {
  // * General Settings
  // Theme defaults
  static const defaultThemeType = ThemeType.system;

  // Stream card defaults
  static const defaultShowThumbnails = true;
  static const defaultLargeStreamCard = false;

  // Links defaults
  static const defaultLaunchUrlExternal = false;

  // Theme options
  @JsonKey(defaultValue: defaultThemeType, unknownEnumValue: ThemeType.system)
  @observable
  var themeType = defaultThemeType;

  // Stream card options
  @JsonKey(defaultValue: defaultShowThumbnails)
  @observable
  var showThumbnails = defaultShowThumbnails;

  @JsonKey(defaultValue: defaultLargeStreamCard)
  @observable
  var largeStreamCard = defaultLargeStreamCard;

  // Links options
  @JsonKey(defaultValue: defaultLaunchUrlExternal)
  @observable
  var launchUrlExternal = defaultLaunchUrlExternal;

  @action
  void resetGeneralSettings() {
    themeType = defaultThemeType;

    largeStreamCard = defaultLargeStreamCard;
    showThumbnails = defaultShowThumbnails;

    launchUrlExternal = defaultLaunchUrlExternal;
  }

  // * Video Settings
  // Player defaults
  static const defaultShowVideo = true;

  // Overlay defaults
  static const defaultShowOverlay = true;
  static const defaultToggleableOverlay = false;
  static const defaultOverlayOpacity = 0.5;

  // Player options
  @JsonKey(defaultValue: defaultShowVideo)
  @observable
  var showVideo = defaultShowVideo;

  // Overlay options
  @JsonKey(defaultValue: defaultShowOverlay)
  @observable
  var showOverlay = defaultShowOverlay;

  @JsonKey(defaultValue: defaultToggleableOverlay)
  @observable
  var toggleableOverlay = defaultToggleableOverlay;

  @JsonKey(defaultValue: defaultOverlayOpacity)
  @observable
  var overlayOpacity = defaultOverlayOpacity;

  @action
  void resetVideoSettings() {
    showVideo = defaultShowVideo;

    showOverlay = defaultShowOverlay;
    toggleableOverlay = defaultToggleableOverlay;
    overlayOpacity = defaultOverlayOpacity;
  }

  // * Chat Settings
  // Message sizing defaults
  static const defaultBadgeScale = 1.0;
  static const defaultEmoteScale = 1.0;
  static const defaultMessageScale = 1.0;
  static const defaultMessageSpacing = 10.0;
  static const defaultFontSize = 12.0;

  // Message appearance defaults
  static const defaultUseReadableColors = true;
  static const defaultShowDeletedMessages = false;
  static const defaultShowChatMessageDividers = false;
  static const defaultTimestampType = TimestampType.disabled;

  // Delay defaults
  static const defaultChatDelay = 0.0;

  // Alert defaults
  static const defaultHighlightFirstTimeChatter = true;
  static const defaultShowUserNotices = true;

  // Layout defaults
  static const defaultShowBottomBar = true;
  static const defaultEmoteMenuButtonOnLeft = false;
  static const defaultChatNotificationsOnBottom = false;

  // Landscape mode defaults
  static const defaultLandscapeChatLeftSide = false;
  static const defaultLandscapeForceVerticalChat = false;
  static const defaultLandscapeCutout = LandscapeCutoutType.none;
  static const defaultChatWidth = 0.3;
  static const defaultFullScreenChatOverlayOpacity = 0.5;

  // Sleep defaults
  static const defaultChatOnlyPreventSleep = false;

  // Autocomplete defaults
  static const defaultAutocomplete = true;

  // Message sizing options
  @JsonKey(defaultValue: defaultBadgeScale)
  @observable
  var badgeScale = defaultBadgeScale;

  @JsonKey(defaultValue: defaultEmoteScale)
  @observable
  var emoteScale = defaultEmoteScale;

  @JsonKey(defaultValue: defaultMessageScale)
  @observable
  var messageScale = defaultMessageScale;

  @JsonKey(defaultValue: defaultMessageSpacing)
  @observable
  var messageSpacing = defaultMessageSpacing;

  @JsonKey(defaultValue: defaultFontSize)
  @observable
  var fontSize = defaultFontSize;

  // Message appearance options
  @JsonKey(defaultValue: defaultUseReadableColors)
  @observable
  var useReadableColors = defaultUseReadableColors;

  @JsonKey(defaultValue: defaultShowDeletedMessages)
  @observable
  var showDeletedMessages = defaultShowDeletedMessages;

  @JsonKey(defaultValue: defaultShowChatMessageDividers)
  @observable
  var showChatMessageDividers = defaultShowChatMessageDividers;

  @JsonKey(
      defaultValue: defaultTimestampType,
      unknownEnumValue: TimestampType.disabled)
  @observable
  var timestampType = defaultTimestampType;

  // Delay options
  @JsonKey(defaultValue: defaultChatDelay)
  @observable
  var chatDelay = defaultChatDelay;

  // Alert options
  @JsonKey(defaultValue: defaultHighlightFirstTimeChatter)
  @observable
  var highlightFirstTimeChatter = defaultHighlightFirstTimeChatter;

  @JsonKey(defaultValue: defaultShowUserNotices)
  @observable
  var showUserNotices = defaultHighlightFirstTimeChatter;

  // Layout options
  @JsonKey(defaultValue: defaultShowBottomBar)
  @observable
  var showBottomBar = defaultShowBottomBar;

  @JsonKey(defaultValue: defaultEmoteMenuButtonOnLeft)
  @observable
  var emoteMenuButtonOnLeft = defaultEmoteMenuButtonOnLeft;

  @JsonKey(defaultValue: defaultChatNotificationsOnBottom)
  @observable
  var chatNotificationsOnBottom = defaultChatNotificationsOnBottom;

  // Landscape mode options
  @JsonKey(defaultValue: defaultLandscapeChatLeftSide)
  @observable
  var landscapeChatLeftSide = defaultLandscapeChatLeftSide;

  @JsonKey(defaultValue: defaultLandscapeForceVerticalChat)
  @observable
  var landscapeForceVerticalChat = defaultLandscapeForceVerticalChat;

  @JsonKey(defaultValue: defaultLandscapeCutout)
  @observable
  var landscapeCutout = defaultLandscapeCutout;

  @JsonKey(defaultValue: defaultChatWidth)
  @observable
  var chatWidth = defaultChatWidth;

  @JsonKey(defaultValue: defaultFullScreenChatOverlayOpacity)
  @observable
  var fullScreenChatOverlayOpacity = defaultFullScreenChatOverlayOpacity;

  // Sleep options
  @JsonKey(defaultValue: defaultChatOnlyPreventSleep)
  @observable
  var chatOnlyPreventSleep = defaultChatOnlyPreventSleep;

  // Autocomplete options
  @JsonKey(defaultValue: defaultAutocomplete)
  @observable
  var autocomplete = defaultAutocomplete;

  @action
  void resetChatSettings() {
    badgeScale = defaultBadgeScale;
    emoteScale = defaultEmoteScale;
    messageScale = defaultMessageScale;
    messageSpacing = defaultMessageSpacing;
    fontSize = defaultFontSize;

    useReadableColors = defaultUseReadableColors;
    showDeletedMessages = defaultShowDeletedMessages;
    showChatMessageDividers = defaultShowChatMessageDividers;
    timestampType = defaultTimestampType;

    chatDelay = defaultChatDelay;

    highlightFirstTimeChatter = defaultHighlightFirstTimeChatter;
    showUserNotices = defaultShowUserNotices;

    showBottomBar = defaultShowBottomBar;
    emoteMenuButtonOnLeft = defaultEmoteMenuButtonOnLeft;
    chatNotificationsOnBottom = defaultChatNotificationsOnBottom;

    landscapeChatLeftSide = defaultLandscapeChatLeftSide;
    landscapeForceVerticalChat = defaultLandscapeForceVerticalChat;
    landscapeCutout = defaultLandscapeCutout;
    chatWidth = defaultChatWidth;
    fullScreenChatOverlayOpacity = defaultFullScreenChatOverlayOpacity;

    chatOnlyPreventSleep = defaultChatOnlyPreventSleep;
    autocomplete = defaultAutocomplete;
  }

  // * Other settings
  static const defaultShareCrashLogsAndAnalytics = true;

  @JsonKey(defaultValue: defaultShareCrashLogsAndAnalytics)
  @observable
  var shareCrashLogsAndAnalytics = defaultShareCrashLogsAndAnalytics;

  @action
  void resetOtherSettings() {
    shareCrashLogsAndAnalytics = defaultShareCrashLogsAndAnalytics;
  }

  // * Global configs
  static const defaultFullScreen = false;
  static const defaultFullScreenChatOverlay = false;

  @JsonKey(defaultValue: defaultFullScreen)
  @observable
  var fullScreen = defaultFullScreen;

  @JsonKey(defaultValue: defaultFullScreenChatOverlay)
  @observable
  var fullScreenChatOverlay = defaultFullScreenChatOverlay;

  @action
  void resetGlobalConfigs() {
    fullScreen = defaultFullScreen;
    fullScreenChatOverlay = defaultFullScreenChatOverlay;
  }

  @action
  void resetAllSettings() {
    resetGeneralSettings();
    resetVideoSettings();
    resetChatSettings();
    resetOtherSettings();
    resetGlobalConfigs();
  }
}

const themeNames = ['System', 'Light', 'Dark', 'Black'];

enum ThemeType {
  system,
  light,
  dark,
  black,
}

const timestampNames = ['Disabled', '12-hour', '24-hour'];

enum TimestampType {
  disabled,
  twelve,
  twentyFour,
}

const landscapeCutoutNames = ['None', 'Left', 'Right', 'Both'];

enum LandscapeCutoutType {
  none,
  left,
  right,
  both,
}

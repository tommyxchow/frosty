import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'settings_store.g.dart';

@JsonSerializable()
class SettingsStore extends _SettingsStoreBase with _$SettingsStore {
  SettingsStore();

  factory SettingsStore.fromJson(Map<String, dynamic> json) => _$SettingsStoreFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsStoreToJson(this);
}

abstract class _SettingsStoreBase with Store {
  // * General Settings
  static const defaultThemeType = ThemeType.system;
  static const defaultShowThumbnails = true;
  static const defaultLargeStreamCard = false;
  static const defaultShowThumbnailUptime = false;
  static const defaultLaunchUrlExternal = false;

  @JsonKey(defaultValue: defaultThemeType, unknownEnumValue: ThemeType.system)
  @observable
  var themeType = defaultThemeType;

  @JsonKey(defaultValue: defaultShowThumbnails)
  @observable
  var showThumbnails = defaultShowThumbnails;

  @JsonKey(defaultValue: defaultLargeStreamCard)
  @observable
  var largeStreamCard = defaultLargeStreamCard;

  @JsonKey(defaultValue: defaultShowThumbnailUptime)
  @observable
  var showThumbnailUptime = defaultShowThumbnailUptime;

  @JsonKey(defaultValue: defaultLaunchUrlExternal)
  @observable
  var launchUrlExternal = defaultLaunchUrlExternal;

  @action
  void resetGeneralSettings() {
    themeType = defaultThemeType;
    showThumbnails = defaultShowThumbnails;
    largeStreamCard = defaultLargeStreamCard;
    showThumbnailUptime = defaultShowThumbnailUptime;
    launchUrlExternal = defaultLaunchUrlExternal;
  }

  // * Video Settings
  static const defaultShowVideo = true;
  static const defaultShowOverlay = true;
  static const defaultToggleableOverlay = false;
  static const defaultPictureInPicture = false;
  static const defaultOverlayOpacity = 0.5;

  @JsonKey(defaultValue: defaultShowVideo)
  @observable
  var showVideo = defaultShowVideo;

  @JsonKey(defaultValue: defaultShowOverlay)
  @observable
  var showOverlay = defaultShowOverlay;

  @JsonKey(defaultValue: defaultToggleableOverlay)
  @observable
  var toggleableOverlay = defaultToggleableOverlay;

  @JsonKey(defaultValue: defaultPictureInPicture)
  @observable
  var pictureInPicture = defaultPictureInPicture;

  @JsonKey(defaultValue: defaultOverlayOpacity)
  @observable
  var overlayOpacity = defaultOverlayOpacity;

  @action
  void resetVideoSettings() {
    showVideo = defaultShowVideo;
    showOverlay = defaultShowOverlay;
    toggleableOverlay = defaultToggleableOverlay;
    pictureInPicture = defaultPictureInPicture;
    overlayOpacity = defaultOverlayOpacity;
  }

  // * Chat Settings
  static const defaultChatDelay = 0.0;
  static const defaultChatOnlyPreventSleep = true;
  static const defaultAutocomplete = true;
  static const defaultLandscapeCutout = LandscapeCutoutType.none;

  static const defaultShowBottomBar = true;
  static const defaultEmoteMenuButtonOnLeft = false;
  static const defaultLandscapeChatLeftSide = false;
  static const defaultChatNotificationsOnBottom = false;
  static const defaultChatWidth = 0.3;
  static const defaultFullScreenChatOverlayOpacity = 0.5;

  static const defaultShowZeroWidth = false;

  static const defaultUseReadableColors = true;
  static const defaultShowDeletedMessages = false;
  static const defaultShowChatMessageDividers = false;
  static const defaultTimestampType = TimestampType.disabled;

  static const defaultHighlightFirstTimeChatter = true;
  static const defaultShowUserNotices = true;

  static const defaultBadgeScale = 1.0;
  static const defaultEmoteScale = 1.0;
  static const defaultMessageScale = 1.0;
  static const defaultMessageSpacing = 10.0;
  static const defaultFontSize = 12.0;

  @JsonKey(defaultValue: defaultChatDelay)
  @observable
  var chatDelay = defaultChatDelay;

  @JsonKey(defaultValue: defaultChatOnlyPreventSleep)
  @observable
  var chatOnlyPreventSleep = defaultChatOnlyPreventSleep;

  @JsonKey(defaultValue: defaultAutocomplete)
  @observable
  var autocomplete = defaultAutocomplete;

  @JsonKey(defaultValue: defaultShowBottomBar)
  @observable
  var showBottomBar = defaultShowBottomBar;

  @JsonKey(defaultValue: defaultEmoteMenuButtonOnLeft)
  @observable
  var emoteMenuButtonOnLeft = defaultEmoteMenuButtonOnLeft;

  @JsonKey(defaultValue: defaultLandscapeChatLeftSide)
  @observable
  var landscapeChatLeftSide = defaultLandscapeChatLeftSide;

  @JsonKey(defaultValue: defaultChatNotificationsOnBottom)
  @observable
  var chatNotificationsOnBottom = defaultChatNotificationsOnBottom;

  @JsonKey(defaultValue: defaultLandscapeCutout)
  @observable
  var landscapeCutout = defaultLandscapeCutout;

  @JsonKey(defaultValue: defaultChatWidth)
  @observable
  var chatWidth = defaultChatWidth;

  @JsonKey(defaultValue: defaultFullScreenChatOverlayOpacity)
  @observable
  var fullScreenChatOverlayOpacity = defaultFullScreenChatOverlayOpacity;

  @JsonKey(defaultValue: defaultShowZeroWidth)
  @observable
  var showZeroWidth = defaultShowZeroWidth;

  @JsonKey(defaultValue: defaultUseReadableColors)
  @observable
  var useReadableColors = defaultUseReadableColors;

  @JsonKey(defaultValue: defaultShowDeletedMessages)
  @observable
  var showDeletedMessages = defaultShowDeletedMessages;

  @JsonKey(defaultValue: defaultShowChatMessageDividers)
  @observable
  var showChatMessageDividers = defaultShowChatMessageDividers;

  @JsonKey(defaultValue: defaultTimestampType, unknownEnumValue: TimestampType.disabled)
  @observable
  var timestampType = defaultTimestampType;

  @JsonKey(defaultValue: defaultHighlightFirstTimeChatter)
  @observable
  var highlightFirstTimeChatter = defaultHighlightFirstTimeChatter;

  @JsonKey(defaultValue: defaultShowUserNotices)
  @observable
  var showUserNotices = defaultHighlightFirstTimeChatter;

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

  @action
  void resetChatSettings() {
    chatDelay = defaultChatDelay;
    chatOnlyPreventSleep = defaultChatOnlyPreventSleep;
    autocomplete = defaultAutocomplete;
    showBottomBar = defaultShowBottomBar;
    emoteMenuButtonOnLeft = defaultEmoteMenuButtonOnLeft;
    landscapeChatLeftSide = defaultLandscapeChatLeftSide;
    chatNotificationsOnBottom = defaultChatNotificationsOnBottom;
    landscapeCutout = defaultLandscapeCutout;
    chatWidth = defaultChatWidth;
    fullScreenChatOverlayOpacity = defaultFullScreenChatOverlayOpacity;
    showZeroWidth = defaultShowZeroWidth;
    useReadableColors = defaultUseReadableColors;
    showDeletedMessages = defaultShowDeletedMessages;
    showChatMessageDividers = defaultShowChatMessageDividers;
    timestampType = defaultTimestampType;
    highlightFirstTimeChatter = defaultHighlightFirstTimeChatter;
    showUserNotices = defaultShowUserNotices;
    badgeScale = defaultBadgeScale;
    emoteScale = defaultEmoteScale;
    messageScale = defaultMessageScale;
    messageSpacing = defaultMessageSpacing;
    fontSize = defaultFontSize;
  }

  // * Other settings
  static const defaultSendCrashLogs = true;

  @JsonKey(defaultValue: defaultSendCrashLogs)
  @observable
  var sendCrashLogs = defaultSendCrashLogs;

  @action
  void resetOtherSettings() {
    sendCrashLogs = defaultSendCrashLogs;
  }

  // * Global configs
  static const defaultFullScreen = false;
  static const defaultExpandInfo = true;
  static const defaultFullScreenChatOverlay = false;

  @JsonKey(defaultValue: defaultFullScreen)
  @observable
  var fullScreen = defaultFullScreen;

  @JsonKey(defaultValue: defaultExpandInfo)
  @observable
  var expandInfo = defaultExpandInfo;

  @JsonKey(defaultValue: defaultFullScreenChatOverlay)
  @observable
  var fullScreenChatOverlay = defaultFullScreenChatOverlay;

  @action
  void resetGlobalConfigs() {
    fullScreen = defaultFullScreen;
    expandInfo = defaultExpandInfo;
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

enum ThemeType {
  system,
  light,
  dark,
  black,
}

enum TimestampType {
  disabled,
  twelve,
  twentyFour,
}

enum LandscapeCutoutType {
  none,
  left,
  right,
  both,
}

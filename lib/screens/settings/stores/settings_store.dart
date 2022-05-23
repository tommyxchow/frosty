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

  static const defaultShowThumbnailUptime = false;

  static const defaultShowThumbnails = true;

  static const defaultLaunchUrlExternal = false;

  @JsonKey(defaultValue: defaultThemeType, unknownEnumValue: ThemeType.system)
  @observable
  var themeType = defaultThemeType;

  @JsonKey(defaultValue: defaultShowThumbnailUptime)
  @observable
  var showThumbnailUptime = defaultShowThumbnailUptime;

  @JsonKey(defaultValue: defaultShowThumbnails)
  @observable
  var showThumbnails = defaultShowThumbnails;

  @JsonKey(defaultValue: defaultLaunchUrlExternal)
  @observable
  var launchUrlExternal = defaultLaunchUrlExternal;

  // * Video Settings
  static const defaultShowVideo = true;

  static const defaultShowOverlay = true;

  static const defaultToggleableOverlay = false;

  static const defaultPictureInPicture = false;

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

  // * Chat Settings
  static const defaultShowBottomBar = true;

  static const defaultShowDeletedMessages = false;

  static const defaultShowZeroWidth = false;

  static const defaultShowChatMessageDividers = false;

  static const defaultTimestampType = TimestampType.disabled;

  static const defaultUseReadableColors = true;

  static const defaultMessageScale = 1.0;

  static const defaultFontSize = 12.0;

  static const defaultMessageSpacing = 10.0;

  static const defaultBadgeScale = 1.0;

  static const defaultEmoteScale = 1.0;

  static const defaultEmoteAutocomplete = true;

  @JsonKey(defaultValue: defaultShowBottomBar)
  @observable
  var showBottomBar = defaultShowBottomBar;

  @JsonKey(defaultValue: defaultShowDeletedMessages)
  @observable
  var showDeletedMessages = defaultShowDeletedMessages;

  @JsonKey(defaultValue: defaultShowZeroWidth)
  @observable
  var showZeroWidth = defaultShowZeroWidth;

  @JsonKey(defaultValue: defaultShowChatMessageDividers)
  @observable
  var showChatMessageDividers = defaultShowChatMessageDividers;

  @JsonKey(defaultValue: defaultTimestampType, unknownEnumValue: TimestampType.disabled)
  @observable
  var timestampType = defaultTimestampType;

  @JsonKey(defaultValue: defaultUseReadableColors)
  @observable
  var useReadableColors = defaultUseReadableColors;

  @JsonKey(defaultValue: defaultFontSize)
  @observable
  var fontSize = defaultFontSize;

  @JsonKey(defaultValue: defaultMessageSpacing)
  @observable
  var messageSpacing = defaultMessageSpacing;

  @JsonKey(defaultValue: defaultMessageScale)
  @observable
  var messageScale = defaultMessageScale;

  @JsonKey(defaultValue: defaultBadgeScale)
  @observable
  var badgeScale = defaultBadgeScale;

  @JsonKey(defaultValue: defaultEmoteScale)
  @observable
  var emoteScale = defaultEmoteScale;

  @JsonKey(defaultValue: defaultEmoteAutocomplete)
  @observable
  var emoteAutocomplete = defaultEmoteAutocomplete;

  // * Other settings
  static const defaultSendCrashLogs = true;

  @JsonKey(defaultValue: defaultSendCrashLogs)
  @observable
  var sendCrashLogs = defaultSendCrashLogs;

  // * Global configs
  static const defaultFullScreen = false;

  static const defaultExpandInfo = true;

  @JsonKey(defaultValue: defaultFullScreen)
  @observable
  var fullScreen = defaultFullScreen;

  @JsonKey(defaultValue: defaultExpandInfo)
  @observable
  var expandInfo = defaultExpandInfo;

  @action
  void reset() {
    // * General Settings
    themeType = defaultThemeType;
    showThumbnailUptime = defaultShowThumbnailUptime;
    showThumbnails = defaultShowThumbnails;
    launchUrlExternal = defaultLaunchUrlExternal;

    // * Video Settings
    showVideo = defaultShowVideo;
    showOverlay = defaultShowOverlay;
    toggleableOverlay = defaultToggleableOverlay;
    pictureInPicture = defaultPictureInPicture;

    // * Chat Settings
    showBottomBar = defaultShowBottomBar;
    showDeletedMessages = defaultShowDeletedMessages;
    showZeroWidth = defaultShowZeroWidth;
    showChatMessageDividers = defaultShowChatMessageDividers;
    timestampType = defaultTimestampType;
    useReadableColors = defaultUseReadableColors;
    messageScale = defaultMessageScale;
    fontSize = defaultFontSize;
    messageSpacing = defaultMessageSpacing;
    badgeScale = defaultBadgeScale;
    emoteScale = defaultEmoteScale;
    emoteAutocomplete = defaultEmoteAutocomplete;

    // * Other settings
    sendCrashLogs = defaultSendCrashLogs;

    // * Global configs
    fullScreen = defaultFullScreen;
    expandInfo = defaultExpandInfo;
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

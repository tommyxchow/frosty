import 'package:frosty/screens/channel/chat/stores/chat_tabs_store.dart';
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
  static const defaultAccentColor = 0xff9146ff;

  // Stream card defaults
  static const defaultShowThumbnails = true;
  static const defaultLargeStreamCard = false;

  // Links defaults
  static const defaultLaunchUrlExternal = false;

  // Theme options
  @JsonKey(defaultValue: defaultThemeType, unknownEnumValue: ThemeType.system)
  @observable
  var themeType = defaultThemeType;

  @JsonKey(defaultValue: defaultAccentColor)
  @observable
  var accentColor = defaultAccentColor;

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
    accentColor = defaultAccentColor;

    largeStreamCard = defaultLargeStreamCard;
    showThumbnails = defaultShowThumbnails;

    launchUrlExternal = defaultLaunchUrlExternal;
  }

  // * Video Settings
  // Player defaults
  static const defaultShowVideo = true;
  static const defaultDefaultToHighestQuality = false;
  static const defaultUseTextureRendering = true;
  static const defaultUseNativePlayer = false;

  static const defaultShowOverlay = true;
  static const defaultToggleableOverlay = false;
  static const defaultShowLatency = false;

  // Player options
  @JsonKey(defaultValue: defaultShowVideo)
  @observable
  var showVideo = defaultShowVideo;

  @JsonKey(defaultValue: defaultDefaultToHighestQuality)
  @observable
  var defaultToHighestQuality = defaultDefaultToHighestQuality;

  @JsonKey(defaultValue: defaultUseTextureRendering)
  @observable
  var useTextureRendering = defaultUseTextureRendering;

  @JsonKey(defaultValue: defaultUseNativePlayer)
  @observable
  var useNativePlayer = defaultUseNativePlayer;

  // Overlay options
  @JsonKey(defaultValue: defaultShowOverlay)
  @observable
  var showOverlay = defaultShowOverlay;

  @JsonKey(defaultValue: defaultToggleableOverlay)
  @observable
  var toggleableOverlay = defaultToggleableOverlay;

  @JsonKey(defaultValue: defaultShowLatency)
  @observable
  var showLatency = defaultShowLatency;

  @action
  void resetVideoSettings() {
    showVideo = defaultShowVideo;
    defaultToHighestQuality = defaultDefaultToHighestQuality;
    useTextureRendering = defaultUseTextureRendering;
    useNativePlayer = defaultUseNativePlayer;

    showOverlay = defaultShowOverlay;
    toggleableOverlay = defaultToggleableOverlay;
    showLatency = defaultShowLatency;
  }

  // * Chat Settings

  // -- Messages --
  // Sizing defaults
  static const defaultBadgeScale = 1.0;
  static const defaultEmoteScale = 1.0;
  static const defaultMessageScale = 1.0;
  static const defaultMessageSpacing = 8.0;
  static const defaultFontSize = 12.0;

  // Appearance defaults
  static const defaultShowDeletedMessages = false;
  static const defaultShowChatMessageDividers = false;
  static const defaultTimestampType = TimestampType.disabled;

  // Alert defaults
  static const defaultHighlightFirstTimeChatter = true;
  static const defaultShowUserNotices = true;

  // -- Emotes & Badges --
  static const defaultShowTwitchEmotes = true;
  static const defaultShowTwitchBadges = true;
  static const defaultShow7TVEmotes = true;
  static const defaultShowBTTVEmotes = true;
  static const defaultShowBTTVBadges = true;
  static const defaultShowFFZEmotes = true;
  static const defaultShowFFZBadges = true;

  // -- Layout --
  static const defaultEmoteMenuButtonOnLeft = false;
  static const defaultPersistChatTabs = true;
  static const defaultSecondaryTabs = <PersistedChatTab>[];
  static const defaultLandscapeChatLeftSide = false;
  static const defaultLandscapeForceVerticalChat = false;
  static const defaultLandscapeCutout = LandscapeCutoutType.none;
  static const defaultChatWidth = 0.2;
  static const defaultFullScreenChatOverlayOpacity = 0.5;

  // -- Behavior --
  static const defaultKeepScreenAwake = true;
  static const defaultAutocomplete = true;
  static const defaultShowRecentMessages = false;
  static const defaultAutoSyncChatDelay = false;
  static const defaultChatDelay = 0.0;
  static const defaultMutedWords = <String>[];
  static const defaultMatchWholeWord = true;

  // Messages options
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

  @JsonKey(defaultValue: defaultShowDeletedMessages)
  @observable
  var showDeletedMessages = defaultShowDeletedMessages;

  @JsonKey(defaultValue: defaultShowChatMessageDividers)
  @observable
  var showChatMessageDividers = defaultShowChatMessageDividers;

  @JsonKey(
    defaultValue: defaultTimestampType,
    unknownEnumValue: TimestampType.disabled,
  )
  @observable
  var timestampType = defaultTimestampType;

  @JsonKey(defaultValue: defaultHighlightFirstTimeChatter)
  @observable
  var highlightFirstTimeChatter = defaultHighlightFirstTimeChatter;

  @JsonKey(defaultValue: defaultShowUserNotices)
  @observable
  var showUserNotices = defaultShowUserNotices;

  // Emotes & Badges options
  @JsonKey(defaultValue: defaultShowTwitchEmotes)
  @observable
  var showTwitchEmotes = defaultShowTwitchEmotes;

  @JsonKey(defaultValue: defaultShowTwitchBadges)
  @observable
  var showTwitchBadges = defaultShowTwitchBadges;

  @JsonKey(defaultValue: defaultShow7TVEmotes)
  @observable
  var show7TVEmotes = defaultShow7TVEmotes;

  @JsonKey(defaultValue: defaultShowBTTVEmotes)
  @observable
  var showBTTVEmotes = defaultShowBTTVEmotes;

  @JsonKey(defaultValue: defaultShowBTTVBadges)
  @observable
  var showBTTVBadges = defaultShowBTTVBadges;

  @JsonKey(defaultValue: defaultShowFFZEmotes)
  @observable
  var showFFZEmotes = defaultShowFFZEmotes;

  @JsonKey(defaultValue: defaultShowFFZBadges)
  @observable
  var showFFZBadges = defaultShowFFZBadges;

  // Layout options
  @JsonKey(defaultValue: defaultEmoteMenuButtonOnLeft)
  @observable
  var emoteMenuButtonOnLeft = defaultEmoteMenuButtonOnLeft;

  @JsonKey(defaultValue: defaultPersistChatTabs)
  @observable
  var persistChatTabs = defaultPersistChatTabs;

  @JsonKey(defaultValue: defaultSecondaryTabs)
  @observable
  var secondaryTabs = defaultSecondaryTabs;

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

  // Behavior options
  @JsonKey(defaultValue: defaultKeepScreenAwake)
  @observable
  var keepScreenAwake = defaultKeepScreenAwake;

  @JsonKey(defaultValue: defaultAutocomplete)
  @observable
  var autocomplete = defaultAutocomplete;

  @JsonKey(defaultValue: defaultShowRecentMessages)
  @observable
  var showRecentMessages = defaultShowRecentMessages;

  @JsonKey(defaultValue: defaultAutoSyncChatDelay)
  @observable
  var autoSyncChatDelay = defaultAutoSyncChatDelay;

  @JsonKey(defaultValue: defaultChatDelay)
  @observable
  var chatDelay = defaultChatDelay;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @observable
  var syncedChatDelay = defaultChatDelay;

  @computed
  double get effectiveChatDelay =>
      autoSyncChatDelay ? syncedChatDelay : chatDelay;

  @JsonKey(defaultValue: defaultMutedWords)
  @observable
  List<String> mutedWords = defaultMutedWords;

  @JsonKey(defaultValue: defaultMatchWholeWord)
  @observable
  bool matchWholeWord = defaultMatchWholeWord;

  @action
  void resetChatSettings() {
    // Messages
    badgeScale = defaultBadgeScale;
    emoteScale = defaultEmoteScale;
    messageScale = defaultMessageScale;
    messageSpacing = defaultMessageSpacing;
    fontSize = defaultFontSize;
    showDeletedMessages = defaultShowDeletedMessages;
    showChatMessageDividers = defaultShowChatMessageDividers;
    timestampType = defaultTimestampType;
    highlightFirstTimeChatter = defaultHighlightFirstTimeChatter;
    showUserNotices = defaultShowUserNotices;

    // Emotes & Badges
    showTwitchEmotes = defaultShowTwitchEmotes;
    showTwitchBadges = defaultShowTwitchBadges;
    show7TVEmotes = defaultShow7TVEmotes;
    showBTTVEmotes = defaultShowBTTVEmotes;
    showBTTVBadges = defaultShowBTTVBadges;
    showFFZEmotes = defaultShowFFZEmotes;
    showFFZBadges = defaultShowFFZBadges;

    // Layout
    emoteMenuButtonOnLeft = defaultEmoteMenuButtonOnLeft;
    persistChatTabs = defaultPersistChatTabs;
    secondaryTabs = defaultSecondaryTabs;
    landscapeChatLeftSide = defaultLandscapeChatLeftSide;
    landscapeForceVerticalChat = defaultLandscapeForceVerticalChat;
    landscapeCutout = defaultLandscapeCutout;
    chatWidth = defaultChatWidth;
    fullScreenChatOverlayOpacity = defaultFullScreenChatOverlayOpacity;

    // Behavior
    keepScreenAwake = defaultKeepScreenAwake;
    autocomplete = defaultAutocomplete;
    showRecentMessages = defaultShowRecentMessages;
    autoSyncChatDelay = defaultAutoSyncChatDelay;
    chatDelay = defaultChatDelay;
    syncedChatDelay = defaultChatDelay;
    mutedWords = defaultMutedWords;
    matchWholeWord = defaultMatchWholeWord;
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
  static const defaultPinnedChannelIds = <String>[];

  @JsonKey(defaultValue: defaultFullScreen)
  @observable
  var fullScreen = defaultFullScreen;

  @JsonKey(defaultValue: defaultFullScreenChatOverlay)
  @observable
  var fullScreenChatOverlay = defaultFullScreenChatOverlay;

  @JsonKey(defaultValue: defaultPinnedChannelIds)
  @observable
  var pinnedChannelIds = defaultPinnedChannelIds;

  @action
  void resetGlobalConfigs() {
    fullScreen = defaultFullScreen;
    fullScreenChatOverlay = defaultFullScreenChatOverlay;
    pinnedChannelIds = defaultPinnedChannelIds;
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

const themeNames = ['System', 'Light', 'Dark'];

enum ThemeType { system, light, dark }

const timestampNames = ['Disabled', '12-hour', '24-hour'];

enum TimestampType { disabled, twelve, twentyFour }

const landscapeCutoutNames = ['None', 'Left', 'Right', 'Both'];

enum LandscapeCutoutType { none, left, right, both }

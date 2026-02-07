import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';

void main() {
  group('SettingsStore JSON serialization', () {
    test('fromJson with empty map returns all defaults', () {
      final store = SettingsStore.fromJson({});

      expect(store.themeType, ThemeType.system);
      expect(store.accentColor, 0xff9146ff);
      expect(store.showThumbnails, isTrue);
      expect(store.largeStreamCard, isFalse);
      expect(store.launchUrlExternal, isFalse);
      expect(store.showVideo, isTrue);
      expect(store.defaultToHighestQuality, isFalse);
      expect(store.useTextureRendering, isTrue);
      expect(store.showOverlay, isTrue);
      expect(store.toggleableOverlay, isFalse);
      expect(store.showLatency, isFalse);
      expect(store.badgeScale, 1.0);
      expect(store.emoteScale, 1.0);
      expect(store.messageScale, 1.0);
      expect(store.messageSpacing, 8.0);
      expect(store.fontSize, 12.0);
      expect(store.showDeletedMessages, isFalse);
      expect(store.showChatMessageDividers, isFalse);
      expect(store.timestampType, TimestampType.disabled);
      expect(store.autoSyncChatDelay, isFalse);
      expect(store.chatDelay, 0.0);
      expect(store.highlightFirstTimeChatter, isTrue);
      expect(store.showUserNotices, isTrue);
      expect(store.emoteMenuButtonOnLeft, isFalse);
      expect(store.landscapeChatLeftSide, isFalse);
      expect(store.landscapeForceVerticalChat, isFalse);
      expect(store.landscapeCutout, LandscapeCutoutType.none);
      expect(store.chatWidth, 0.2);
      expect(store.fullScreenChatOverlayOpacity, 0.5);
      expect(store.autocomplete, isTrue);
      expect(store.showTwitchEmotes, isTrue);
      expect(store.showTwitchBadges, isTrue);
      expect(store.show7TVEmotes, isTrue);
      expect(store.showBTTVEmotes, isTrue);
      expect(store.showBTTVBadges, isTrue);
      expect(store.showFFZEmotes, isTrue);
      expect(store.showFFZBadges, isTrue);
      expect(store.showRecentMessages, isFalse);
      expect(store.persistChatTabs, isTrue);
      expect(store.secondaryTabs, isEmpty);
      expect(store.mutedWords, isEmpty);
      expect(store.matchWholeWord, isTrue);
      expect(store.shareCrashLogsAndAnalytics, isTrue);
      expect(store.fullScreen, isFalse);
      expect(store.fullScreenChatOverlay, isFalse);
      expect(store.pinnedChannelIds, isEmpty);
    });

    test('roundtrip serialization preserves non-default values', () {
      final store = SettingsStore.fromJson({});

      // Set non-default values
      store.themeType = ThemeType.dark;
      store.accentColor = 0xFF00FF00;
      store.showThumbnails = false;
      store.fontSize = 16.0;
      store.chatDelay = 5.0;
      store.showVideo = false;
      store.timestampType = TimestampType.twelve;
      store.landscapeCutout = LandscapeCutoutType.both;
      store.mutedWords = ['spam', 'bad'];
      store.pinnedChannelIds = ['ch1', 'ch2'];

      final json = store.toJson();
      final restored = SettingsStore.fromJson(json);

      expect(restored.themeType, ThemeType.dark);
      expect(restored.accentColor, 0xFF00FF00);
      expect(restored.showThumbnails, isFalse);
      expect(restored.fontSize, 16.0);
      expect(restored.chatDelay, 5.0);
      expect(restored.showVideo, isFalse);
      expect(restored.timestampType, TimestampType.twelve);
      expect(restored.landscapeCutout, LandscapeCutoutType.both);
      expect(restored.mutedWords, ['spam', 'bad']);
      expect(restored.pinnedChannelIds, ['ch1', 'ch2']);
    });

    test('unknown ThemeType enum value falls back to system', () {
      final store = SettingsStore.fromJson({
        'themeType': 'nonexistent_theme',
      });
      expect(store.themeType, ThemeType.system);
    });

    test('unknown TimestampType enum value falls back to disabled', () {
      final store = SettingsStore.fromJson({
        'timestampType': 'nonexistent_timestamp',
      });
      expect(store.timestampType, TimestampType.disabled);
    });
  });

  group('SettingsStore reset actions', () {
    test('resetGeneralSettings restores general defaults', () {
      final store = SettingsStore.fromJson({});

      store.themeType = ThemeType.dark;
      store.accentColor = 0xFF00FF00;
      store.showThumbnails = false;
      store.largeStreamCard = true;
      store.launchUrlExternal = true;

      store.resetGeneralSettings();

      expect(store.themeType, ThemeType.system);
      expect(store.accentColor, 0xff9146ff);
      expect(store.showThumbnails, isTrue);
      expect(store.largeStreamCard, isFalse);
      expect(store.launchUrlExternal, isFalse);
    });

    test('resetVideoSettings restores video defaults', () {
      final store = SettingsStore.fromJson({});

      store.showVideo = false;
      store.defaultToHighestQuality = true;
      store.useTextureRendering = false;
      store.showOverlay = false;
      store.toggleableOverlay = true;
      store.showLatency = true;

      store.resetVideoSettings();

      expect(store.showVideo, isTrue);
      expect(store.defaultToHighestQuality, isFalse);
      expect(store.useTextureRendering, isTrue);
      expect(store.showOverlay, isTrue);
      expect(store.toggleableOverlay, isFalse);
      expect(store.showLatency, isFalse);
    });

    test('resetChatSettings restores chat defaults', () {
      final store = SettingsStore.fromJson({});

      store.badgeScale = 2.0;
      store.emoteScale = 2.0;
      store.fontSize = 20.0;
      store.showDeletedMessages = true;
      store.timestampType = TimestampType.twentyFour;
      store.chatDelay = 10.0;
      store.emoteMenuButtonOnLeft = true;
      store.landscapeCutout = LandscapeCutoutType.right;
      store.chatWidth = 0.5;
      store.mutedWords = ['word1'];
      store.showBTTVEmotes = false;
      store.showFFZBadges = false;

      store.resetChatSettings();

      expect(store.badgeScale, 1.0);
      expect(store.emoteScale, 1.0);
      expect(store.fontSize, 12.0);
      expect(store.showDeletedMessages, isFalse);
      expect(store.timestampType, TimestampType.disabled);
      expect(store.chatDelay, 0.0);
      expect(store.emoteMenuButtonOnLeft, isFalse);
      expect(store.landscapeCutout, LandscapeCutoutType.none);
      expect(store.chatWidth, 0.2);
      expect(store.mutedWords, isEmpty);
      expect(store.showBTTVEmotes, isTrue);
      expect(store.showFFZBadges, isTrue);
    });

    test('resetOtherSettings restores other defaults', () {
      final store = SettingsStore.fromJson({});

      store.shareCrashLogsAndAnalytics = false;

      store.resetOtherSettings();

      expect(store.shareCrashLogsAndAnalytics, isTrue);
    });

    test('resetGlobalConfigs restores global config defaults', () {
      final store = SettingsStore.fromJson({});

      store.fullScreen = true;
      store.fullScreenChatOverlay = true;
      store.pinnedChannelIds = ['ch1'];

      store.resetGlobalConfigs();

      expect(store.fullScreen, isFalse);
      expect(store.fullScreenChatOverlay, isFalse);
      expect(store.pinnedChannelIds, isEmpty);
    });

    test('resetAllSettings restores everything to defaults', () {
      final store = SettingsStore.fromJson({});

      // Modify settings across all categories
      store.themeType = ThemeType.light;
      store.showVideo = false;
      store.fontSize = 20.0;
      store.shareCrashLogsAndAnalytics = false;
      store.fullScreen = true;

      store.resetAllSettings();

      expect(store.themeType, ThemeType.system);
      expect(store.showVideo, isTrue);
      expect(store.fontSize, 12.0);
      expect(store.shareCrashLogsAndAnalytics, isTrue);
      expect(store.fullScreen, isFalse);
    });

    test('resetGeneralSettings does not affect video settings', () {
      final store = SettingsStore.fromJson({});

      store.showVideo = false;
      store.themeType = ThemeType.dark;

      store.resetGeneralSettings();

      expect(store.themeType, ThemeType.system);
      expect(store.showVideo, isFalse); // Should remain changed
    });

    test('resetVideoSettings does not affect chat settings', () {
      final store = SettingsStore.fromJson({});

      store.fontSize = 20.0;
      store.showLatency = true;

      store.resetVideoSettings();

      expect(store.showLatency, isFalse);
      expect(store.fontSize, 20.0); // Should remain changed
    });
  });

  group('Enums', () {
    test('ThemeType has expected values', () {
      expect(ThemeType.values.length, 3);
      expect(ThemeType.values, contains(ThemeType.system));
      expect(ThemeType.values, contains(ThemeType.light));
      expect(ThemeType.values, contains(ThemeType.dark));
    });

    test('TimestampType has expected values', () {
      expect(TimestampType.values.length, 3);
      expect(TimestampType.values, contains(TimestampType.disabled));
      expect(TimestampType.values, contains(TimestampType.twelve));
      expect(TimestampType.values, contains(TimestampType.twentyFour));
    });

    test('LandscapeCutoutType has expected values', () {
      expect(LandscapeCutoutType.values.length, 4);
      expect(LandscapeCutoutType.values, contains(LandscapeCutoutType.none));
      expect(LandscapeCutoutType.values, contains(LandscapeCutoutType.left));
      expect(LandscapeCutoutType.values, contains(LandscapeCutoutType.right));
      expect(LandscapeCutoutType.values, contains(LandscapeCutoutType.both));
    });

    test('themeNames matches ThemeType order', () {
      expect(themeNames.length, ThemeType.values.length);
      expect(themeNames[0], 'System');
      expect(themeNames[1], 'Light');
      expect(themeNames[2], 'Dark');
    });

    test('timestampNames matches TimestampType order', () {
      expect(timestampNames.length, TimestampType.values.length);
      expect(timestampNames[0], 'Disabled');
      expect(timestampNames[1], '12-hour');
      expect(timestampNames[2], '24-hour');
    });
  });
}

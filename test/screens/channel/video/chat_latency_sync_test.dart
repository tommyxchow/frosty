import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/channel/video/chat_latency_sync.dart';
import 'package:frosty/screens/channel/video/video_timing_constants.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';

void main() {
  // Reference the real constant so assertions track config changes rather
  // than a hardcoded magic number.
  final tolerance =
      VideoTimingConstants.chatSyncDriftToleranceSeconds.toDouble();

  late SettingsStore settingsStore;
  late ChatLatencySync sync;

  setUp(() {
    settingsStore = SettingsStore.fromJson({});
    sync = ChatLatencySync(settingsStore: settingsStore);
  });

  group('ChatLatencySync reset', () {
    test('zeroes syncedChatDelay when autoSyncChatDelay is enabled', () {
      settingsStore.autoSyncChatDelay = true;
      settingsStore.syncedChatDelay = 7.5;

      sync.reset();

      expect(settingsStore.syncedChatDelay, 0.0);
    });

    test('is a no-op when autoSyncChatDelay is disabled', () {
      settingsStore.autoSyncChatDelay = false;
      settingsStore.syncedChatDelay = 7.5;

      sync.reset();

      expect(settingsStore.syncedChatDelay, 7.5);
    });
  });

  group('ChatLatencySync report', () {
    test('does nothing when autoSyncChatDelay is disabled', () {
      settingsStore.autoSyncChatDelay = false;
      settingsStore.syncedChatDelay = 0.0;

      sync.report(12.0);

      expect(settingsStore.syncedChatDelay, 0.0);
    });

    test('writes the first measurement when current delay is zero', () {
      settingsStore.autoSyncChatDelay = true;
      settingsStore.syncedChatDelay = 0.0;

      // Even a tiny value writes because the current value is exactly 0.
      sync.report(0.5);

      expect(settingsStore.syncedChatDelay, 0.5);
    });

    test('writes when drift exceeds the tolerance', () {
      settingsStore.autoSyncChatDelay = true;
      settingsStore.syncedChatDelay = 5.0;

      final report = 5.0 + tolerance + 1.0;
      sync.report(report);

      expect(settingsStore.syncedChatDelay, report);
    });

    test('does not write when drift is within the tolerance', () {
      settingsStore.autoSyncChatDelay = true;
      settingsStore.syncedChatDelay = 5.0;

      // Strictly inside the tolerance band.
      sync.report(5.0 + (tolerance - 0.5));

      expect(settingsStore.syncedChatDelay, 5.0);
    });

    test('does not write when drift is exactly at the tolerance', () {
      settingsStore.autoSyncChatDelay = true;
      settingsStore.syncedChatDelay = 5.0;

      // The code uses strictly-greater-than (`>`), so a drift equal to the
      // tolerance must NOT write.
      sync.report(5.0 + tolerance);

      expect(settingsStore.syncedChatDelay, 5.0);
    });

    test('writes when drift just exceeds the tolerance', () {
      settingsStore.autoSyncChatDelay = true;
      settingsStore.syncedChatDelay = 5.0;

      final report = 5.0 + tolerance + 0.1;
      sync.report(report);

      expect(settingsStore.syncedChatDelay, report);
    });

    test('writes when a downward drift exceeds the tolerance', () {
      settingsStore.autoSyncChatDelay = true;
      settingsStore.syncedChatDelay = 10.0;

      final report = 10.0 - tolerance - 1.0;
      sync.report(report);

      expect(settingsStore.syncedChatDelay, report);
    });
  });
}

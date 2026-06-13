import 'package:frosty/screens/channel/video/video_timing_constants.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';

/// Single owner of `SettingsStore.syncedChatDelay` writes from the video
/// player stores. Previously both stores poked the setting directly,
/// making settings an ad-hoc event bus between video and chat.
class ChatLatencySync {
  ChatLatencySync({required this.settingsStore});

  final SettingsStore settingsStore;

  /// Reset the delay to zero on stream transitions (channel enter, stream
  /// end, chat-only toggle, etc). No-op when auto-sync is disabled.
  void reset() {
    if (settingsStore.autoSyncChatDelay) {
      settingsStore.syncedChatDelay = 0.0;
    }
  }

  /// Push a fresh video-latency measurement. Only writes when drift from
  /// the current value exceeds the tolerance, to avoid thrashing the chat
  /// delay countdown on minor fluctuations.
  void report(double latencySeconds) {
    if (!settingsStore.autoSyncChatDelay) return;
    final current = settingsStore.syncedChatDelay;
    if (current == 0 ||
        (latencySeconds - current).abs() >
            VideoTimingConstants.chatSyncDriftToleranceSeconds) {
      settingsStore.syncedChatDelay = latencySeconds;
    }
  }
}

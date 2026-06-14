/// Named durations and counts used by the video player stores.
/// Central owner so tuning values don't have to be hunted across files.
class VideoTimingConstants {
  VideoTimingConstants._();

  // Latency / chat sync
  static const int highLatencyThresholdSeconds = 30;
  static const int chatSyncDriftToleranceSeconds = 2;

  /// Maximum consecutive high-latency interventions (seek/refresh) before
  /// giving up on latency-driven recovery. Persistent high readings usually
  /// mean device clock skew or a device that can't keep up; looping
  /// recoveries forever makes playback worse, not better.
  static const int maxHighLatencyRecoveries = 3;

  /// Delay before re-checking /streams when the first check reports offline.
  /// Helix transiently drops live streams from results; a single failed
  /// check isn't enough to tear down healthy playback.
  static const offlineConfirmationDelay = Duration(seconds: 2);

  // Overlay
  static const overlayAutoHide = Duration(seconds: 5);
  static const overlayQuickHide = Duration(seconds: 3);

  // Stream info
  static const streamInfoDebounce = Duration(seconds: 5);
  static const webviewStreamInfoInterval = Duration(minutes: 1);

  // WebView housekeeping
  static const jsCleanupInterval = Duration(minutes: 10);
}

/// Named durations and counts used by the video player stores.
/// Central owner so tuning values don't have to be hunted across files.
class VideoTimingConstants {
  VideoTimingConstants._();

  // Stall recovery
  static const stallDetectionDelay = Duration(seconds: 8);
  static const refreshCooldown = Duration(seconds: 15);
  static const initRetryDelay = Duration(seconds: 3);
  static const int maxRefreshAttempts = 3;

  // Latency / chat sync
  static const latencyPollingInterval = Duration(seconds: 30);
  static const int highLatencyThresholdSeconds = 30;
  static const int chatSyncDriftToleranceSeconds = 2;

  // Overlay
  static const overlayAutoHide = Duration(seconds: 5);
  static const overlayQuickHide = Duration(seconds: 3);

  // Stream info
  static const streamInfoDebounce = Duration(seconds: 5);
  static const webviewStreamInfoInterval = Duration(minutes: 1);

  // WebView housekeeping
  static const jsCleanupInterval = Duration(minutes: 10);
}

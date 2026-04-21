/// Named durations and counts used by the video player stores.
/// Central owner so tuning values don't have to be hunted across files.
class VideoTimingConstants {
  VideoTimingConstants._();

  // Stall recovery
  static const stallDetectionDelay = Duration(seconds: 8);
  static const initRetryDelay = Duration(seconds: 3);
  static const int maxRefreshAttempts = 3;

  /// Delay between stall-recovery full refreshes, indexed by attempt number
  /// (0 = first attempt). Attempts beyond the list length fall through to
  /// the error path via [maxRefreshAttempts].
  static const refreshBackoff = <Duration>[
    Duration.zero,
    Duration(seconds: 3),
    Duration(seconds: 8),
  ];

  /// A "play" event arriving within this window after a previous one is
  /// treated as a failed-recovery bounce rather than a fresh successful start.
  static const shortPlayWindow = Duration(seconds: 3);
  /// Number of short-play bounces required before surfacing a tailored error.
  static const int shortPlayLoopThreshold = 3;

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

/// Named durations and counts used by the video player stores.
/// Central owner so tuning values don't have to be hunted across files.
class VideoTimingConstants {
  VideoTimingConstants._();

  // Stall recovery
  //
  // Cross-layer ordering contract: iOS's native notification-stall recovery
  // fires at ~1s, this Dart timer at 8s, and the Android native watchdog
  // (VideoPlayerObserver.kt STALL_WATCHDOG_MS) at 12s. Correctness depends
  // on 1s < stallDetectionDelay < 12s — Dart's attempt-1 seek must pre-empt
  // the Android watchdog's heavier stop()/prepare() recovery, and iOS has
  // no native watchdog so the Dart timer is the only recoverer for silent
  // rate-drops there. Don't tune past either neighbor.
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
  static const shortPlayWindow = Duration(seconds: 10);
  /// Number of short-play bounces required before surfacing a tailored error.
  static const int shortPlayLoopThreshold = 3;

  // Latency / chat sync
  static const latencyPollingInterval = Duration(seconds: 3);
  static const int highLatencyThresholdSeconds = 30;
  static const int chatSyncDriftToleranceSeconds = 2;

  /// Maximum consecutive high-latency interventions (seek/refresh) before
  /// giving up on latency-driven recovery. Persistent high readings usually
  /// mean device clock skew or a device that can't keep up — looping
  /// recoveries forever makes playback worse, not better.
  static const int maxHighLatencyRecoveries = 3;

  /// Latency drift catch-up (iOS only — ExoPlayer does this natively via
  /// LiveConfiguration's min/maxPlaybackSpeed). Engage above 8s, glide at
  /// 1.05x, release at 6s: ~1s of correction per 20s of playback — slow
  /// enough to be inaudible and to never outrun the buffer. The 2s gap
  /// between engage and release is hysteresis so a noisy reading can't
  /// flap the speed. Gross drift (≥[highLatencyThresholdSeconds]) is owned
  /// by seek/refresh recovery, which runs before catch-up is considered.
  static const int catchUpEngageLatencySeconds = 8;
  static const int catchUpDisengageLatencySeconds = 6;
  static const double catchUpPlaybackRate = 1.05;

  /// How long a quality switch may suppress stall classification before the
  /// flag expires. A resolution-only switch never interrupts playback, so no
  /// play/pause event arrives to clear it — without this backstop the flag
  /// sticks for the whole session and disables stall recovery.
  static const qualitySwitchGrace = Duration(seconds: 5);

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
  static const nativeStreamInfoInterval = Duration(seconds: 30);

  // WebView housekeeping
  static const jsCleanupInterval = Duration(minutes: 10);
}

/// Decides when the native player should drop to audio-only because the screen
/// turned off, and what video quality to restore when it turns back on.
///
/// Pure logic with no Flutter/MobX dependency so it can be unit-tested without
/// constructing the heavyweight video store (mirrors ChatLatencySync).
class ScreenLockAudioPolicy {
  int? _savedQualityIndex;

  /// The screen turned off. Returns the audio-only quality index to switch to
  /// (remembering the current index for restore), or null if nothing should
  /// change — disabled, not actively playing, user-paused, offline, mid ad
  /// break, no audio-only quality available, or already audio-only.
  int? onScreenOff({
    required bool backgroundPlaybackEnabled,
    required bool playing,
    required bool userPaused,
    required int currentQualityIndex,
    required int? audioOnlyQualityIndex,
    required bool offline,
    required bool adBreakActive,
  }) {
    if (!backgroundPlaybackEnabled ||
        !playing ||
        userPaused ||
        offline ||
        adBreakActive) {
      return null;
    }
    if (audioOnlyQualityIndex == null ||
        currentQualityIndex == audioOnlyQualityIndex) {
      return null;
    }
    _savedQualityIndex = currentQualityIndex;
    return audioOnlyQualityIndex;
  }

  /// The screen turned on. Returns the quality index to restore (then clears
  /// it), or null if the screen-off didn't switch.
  int? onScreenOn() {
    final saved = _savedQualityIndex;
    _savedQualityIndex = null;
    return saved;
  }

  /// Drop any pending restore (e.g. on dispose or a hard refresh).
  void reset() => _savedQualityIndex = null;
}

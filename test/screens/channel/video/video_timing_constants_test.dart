import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/channel/video/video_timing_constants.dart';

/// Regression guard for timing relationships used by Glacier's WebView video
/// recovery and chat-sync logic.
void main() {
  group('VideoTimingConstants latency vs chat-sync tolerance', () {
    test('highLatencyThreshold is much greater than chatSyncDriftTolerance', () {
      expect(
        VideoTimingConstants.highLatencyThresholdSeconds,
        greaterThan(VideoTimingConstants.chatSyncDriftToleranceSeconds),
        reason:
            'High-latency intervention must only trigger far past the chat-sync '
            'drift tolerance, otherwise normal sync drift could trigger '
            'playback recovery.',
      );
    });

    test('highLatencyThreshold sits comfortably above normal live latency', () {
      expect(
        VideoTimingConstants.highLatencyThresholdSeconds,
        greaterThanOrEqualTo(15),
        reason:
            'highLatencyThresholdSeconds must stay above normal live latency '
            'so healthy playback is not flagged for recovery.',
      );
    });

    test('maxHighLatencyRecoveries is positive and bounded', () {
      expect(VideoTimingConstants.maxHighLatencyRecoveries, greaterThan(0));
      expect(
        VideoTimingConstants.maxHighLatencyRecoveries,
        lessThanOrEqualTo(5),
      );
    });
  });

  group('VideoTimingConstants stream info', () {
    test('polling and debounce intervals are positive', () {
      expect(
        VideoTimingConstants.streamInfoDebounce,
        greaterThan(Duration.zero),
      );
      expect(
        VideoTimingConstants.webviewStreamInfoInterval,
        greaterThan(Duration.zero),
      );
      expect(
        VideoTimingConstants.offlineConfirmationDelay,
        greaterThan(Duration.zero),
      );
    });

    test('offline confirmation is faster than periodic polling', () {
      expect(
        VideoTimingConstants.offlineConfirmationDelay,
        lessThan(VideoTimingConstants.webviewStreamInfoInterval),
      );
    });
  });

  group('VideoTimingConstants overlay and cleanup', () {
    test('overlayQuickHide is not slower than overlayAutoHide', () {
      expect(
        VideoTimingConstants.overlayQuickHide,
        lessThanOrEqualTo(VideoTimingConstants.overlayAutoHide),
      );
    });

    test('jsCleanupInterval is positive', () {
      expect(
        VideoTimingConstants.jsCleanupInterval,
        greaterThan(Duration.zero),
      );
    });
  });
}

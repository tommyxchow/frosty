import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/channel/video/video_timing_constants.dart';

/// Regression guard for the cross-layer ordering invariants documented in
/// [VideoTimingConstants]. These constants are tuned against native code in
/// two other layers (iOS notification-stall recovery and the Android
/// VideoPlayerObserver watchdog) that are NOT visible from Dart. If someone
/// retunes a value past a safe bound, these tests fail with a message quoting
/// the contract so the regression is self-explanatory.
void main() {
  group('VideoTimingConstants stall-timer ordering', () {
    test(
      'stallDetectionDelay sits between iOS ~1s recovery and Android 12s watchdog',
      () {
        final seconds = VideoTimingConstants.stallDetectionDelay.inSeconds;

        expect(
          seconds,
          greaterThan(1),
          reason:
              'Contract: 1s < stallDetectionDelay. iOS native notification-stall '
              'recovery fires at ~1s; the Dart timer must not race ahead of it.',
        );
        expect(
          seconds,
          lessThan(12),
          reason:
              'Contract: stallDetectionDelay < 12s. The Android native watchdog '
              '(VideoPlayerObserver.kt STALL_WATCHDOG_MS) fires at 12s with a '
              'heavier stop()/prepare() recovery. Dart\'s attempt-1 seek must '
              'pre-empt it, so it must fire first.',
        );
      },
    );
  });

  group('VideoTimingConstants refreshBackoff', () {
    test('is non-empty and starts at Duration.zero', () {
      expect(VideoTimingConstants.refreshBackoff, isNotEmpty);
      expect(
        VideoTimingConstants.refreshBackoff.first,
        Duration.zero,
        reason:
            'First refresh attempt should be immediate (0 = first attempt per '
            'the doc comment).',
      );
    });

    test('covers every refresh attempt up to maxRefreshAttempts', () {
      // The comment states attempts beyond the list length fall through to the
      // error path via [maxRefreshAttempts]. So the list must be long enough to
      // back off every attempt before that fall-through, i.e. cover all
      // maxRefreshAttempts attempts.
      expect(
        VideoTimingConstants.refreshBackoff.length,
        greaterThanOrEqualTo(VideoTimingConstants.maxRefreshAttempts),
        reason:
            'refreshBackoff must index every attempt up to maxRefreshAttempts '
            '(${VideoTimingConstants.maxRefreshAttempts}); a shorter list would '
            'drop a backoff and the attempt would fall through to the error '
            'path prematurely.',
      );
    });

    test('delays are monotonically non-decreasing', () {
      final backoff = VideoTimingConstants.refreshBackoff;
      for (var i = 1; i < backoff.length; i++) {
        expect(
          backoff[i],
          greaterThanOrEqualTo(backoff[i - 1]),
          reason:
              'Backoff must not shrink between attempts: index $i '
              '(${backoff[i]}) < index ${i - 1} (${backoff[i - 1]}). '
              'Later retries should wait at least as long as earlier ones.',
        );
      }
    });
  });

  group('VideoTimingConstants latency vs chat-sync tolerance', () {
    test('highLatencyThreshold is much greater than chatSyncDriftTolerance', () {
      expect(
        VideoTimingConstants.highLatencyThresholdSeconds,
        greaterThan(VideoTimingConstants.chatSyncDriftToleranceSeconds),
        reason:
            'High-latency intervention (seek/refresh) must only trigger far '
            'past the chat-sync drift tolerance '
            '(${VideoTimingConstants.chatSyncDriftToleranceSeconds}s); otherwise '
            'normal sync drift would be misread as a latency problem and trigger '
            'recovery.',
      );
    });

    test('highLatencyThreshold sits comfortably above normal live latency', () {
      // Normal live latency is well under ~15s; the threshold must clear that
      // so routine live playback is never flagged as high-latency.
      expect(
        VideoTimingConstants.highLatencyThresholdSeconds,
        greaterThanOrEqualTo(15),
        reason:
            'highLatencyThresholdSeconds must stay above normal live latency '
            '(under ~15s) so healthy playback is not flagged for recovery.',
      );
    });
  });

  group('VideoTimingConstants short-play loop detection', () {
    test('shortPlayWindow is positive', () {
      expect(VideoTimingConstants.shortPlayWindow, greaterThan(Duration.zero));
    });

    test('shortPlayLoopThreshold is a small positive int', () {
      expect(
        VideoTimingConstants.shortPlayLoopThreshold,
        greaterThan(0),
        reason: 'Need at least one bounce to detect a failed-recovery loop.',
      );
      expect(
        VideoTimingConstants.shortPlayLoopThreshold,
        lessThanOrEqualTo(10),
        reason:
            'Threshold should stay small so a tailored error surfaces promptly '
            'rather than after many silent loops.',
      );
    });
  });

  group('VideoTimingConstants overlay ordering', () {
    test('overlayQuickHide is not slower than overlayAutoHide', () {
      expect(
        VideoTimingConstants.overlayQuickHide,
        lessThanOrEqualTo(VideoTimingConstants.overlayAutoHide),
        reason:
            'The quick-hide path must hide the overlay at least as fast as the '
            'auto-hide path; otherwise "quick" would be slower than the default.',
      );
    });
  });

  group('VideoTimingConstants positive intervals', () {
    test('nativeStreamInfoInterval is positive', () {
      expect(
        VideoTimingConstants.nativeStreamInfoInterval,
        greaterThan(Duration.zero),
      );
    });

    test('latencyPollingInterval is positive', () {
      expect(
        VideoTimingConstants.latencyPollingInterval,
        greaterThan(Duration.zero),
      );
    });

    test('maxRefreshAttempts is positive', () {
      expect(VideoTimingConstants.maxRefreshAttempts, greaterThan(0));
    });
  });
}

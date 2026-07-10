import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/channel/video/screen_lock_audio_policy.dart';

void main() {
  late ScreenLockAudioPolicy policy;
  setUp(() => policy = ScreenLockAudioPolicy());

  int? off({
    bool enabled = true,
    bool playing = true,
    bool userPaused = false,
    int current = 2,
    int? audioOnly = 5,
    bool offline = false,
    bool ad = false,
  }) => policy.onScreenOff(
    backgroundPlaybackEnabled: enabled,
    playing: playing,
    userPaused: userPaused,
    currentQualityIndex: current,
    audioOnlyQualityIndex: audioOnly,
    offline: offline,
    adBreakActive: ad,
  );

  test('switches to the audio-only index and restores the prior index', () {
    expect(off(), 5); // current defaults to 2, audio-only to 5
    expect(policy.onScreenOn(), 2);
  });

  test('onScreenOn returns null once consumed', () {
    off();
    policy.onScreenOn();
    expect(policy.onScreenOn(), isNull);
  });

  test('no-op when disabled', () => expect(off(enabled: false), isNull));
  test('no-op when paused', () => expect(off(playing: false), isNull));
  test('no-op when user paused', () => expect(off(userPaused: true), isNull));
  test('no-op when offline', () => expect(off(offline: true), isNull));
  test('no-op during ad break', () => expect(off(ad: true), isNull));
  test(
    'no-op when no audio-only quality',
    () => expect(off(audioOnly: null), isNull),
  );
  test(
    'no-op when already audio-only',
    () => expect(off(current: 5), isNull), // current == audio-only default (5)
  );

  test('onScreenOn returns null if screen-off was a no-op', () {
    off(enabled: false);
    expect(policy.onScreenOn(), isNull);
  });

  test('reset clears a pending restore', () {
    off();
    policy.reset();
    expect(policy.onScreenOn(), isNull);
  });
}

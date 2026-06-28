import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/channel/chat/stores/banned_user_tracker.dart';

void main() {
  late BannedUserTracker tracker;
  final now = DateTime(2026, 6, 28, 12);
  setUp(() => tracker = BannedUserTracker());

  test('an untracked user is not banned', () {
    expect(tracker.isBannedOrTimedOut('1', now), isFalse);
  });

  test('a banned user stays banned (no expiry)', () {
    tracker.recordBan('1');
    expect(tracker.isBannedOrTimedOut('1', now), isTrue);
    expect(
      tracker.isBannedOrTimedOut('1', now.add(const Duration(days: 365))),
      isTrue,
    );
  });

  test('a timed-out user is banned until the timeout expires', () {
    tracker.recordTimeout('1', const Duration(seconds: 60), now);
    expect(tracker.isBannedOrTimedOut('1', now), isTrue);
    expect(
      tracker.isBannedOrTimedOut('1', now.add(const Duration(seconds: 59))),
      isTrue,
    );
    expect(
      tracker.isBannedOrTimedOut('1', now.add(const Duration(seconds: 61))),
      isFalse,
    );
  });

  test('clear lifts a ban', () {
    tracker.recordBan('1');
    tracker.clear('1');
    expect(tracker.isBannedOrTimedOut('1', now), isFalse);
  });

  test('a later permanent ban overrides an earlier timeout', () {
    tracker.recordTimeout('1', const Duration(seconds: 10), now);
    tracker.recordBan('1');
    expect(
      tracker.isBannedOrTimedOut('1', now.add(const Duration(seconds: 30))),
      isTrue,
    );
  });
}

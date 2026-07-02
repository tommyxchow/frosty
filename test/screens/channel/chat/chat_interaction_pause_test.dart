import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/channel/chat/stores/chat_interaction_pause.dart';

void main() {
  late ChatInteractionPause pause;

  setUp(() => pause = ChatInteractionPause());

  // A move clearly past the touch slop (a scroll), and one well within it.
  final beyondSlop = Offset(0, kTouchSlop + 10);
  final withinSlop = Offset(0, kTouchSlop - 5);

  test('is not paused initially', () {
    expect(pause.isPaused, isFalse);
  });

  test('is paused while a stationary pointer is down (long-press candidate)', () {
    pause.pointerDown(1, Offset.zero);

    expect(pause.isPaused, isTrue);
  });

  test('resumes once the pointer is lifted', () {
    pause.pointerDown(1, Offset.zero);
    pause.pointerUp(1);

    expect(pause.isPaused, isFalse);
  });

  test('resumes when the pointer moves beyond the touch slop (scrolling)', () {
    pause.pointerDown(1, Offset.zero);
    pause.pointerMove(1, beyondSlop);

    // The finger is dragging — this is a scroll, not a hold, so the chat must
    // keep flowing rather than freeze.
    expect(pause.isPaused, isFalse);
  });

  test('stays paused for tiny jitter within the touch slop', () {
    pause.pointerDown(1, Offset.zero);
    pause.pointerMove(1, withinSlop);

    expect(pause.isPaused, isTrue);
  });

  test('stays resumed for the rest of the gesture even if the finger drifts '
      'back within slop', () {
    pause.pointerDown(1, Offset.zero);
    pause.pointerMove(1, beyondSlop);
    pause.pointerMove(1, withinSlop);

    // Once a gesture is recognized as a scroll it should not flip back to a
    // hold mid-drag.
    expect(pause.isPaused, isFalse);
  });

  test('stays paused until every stationary pointer lifts (multi-touch)', () {
    pause.pointerDown(1, Offset.zero);
    pause.pointerDown(2, Offset.zero);
    pause.pointerUp(1);

    expect(pause.isPaused, isTrue);

    pause.pointerUp(2);
    expect(pause.isPaused, isFalse);
  });

  test('a stray pointer-up never leaves the gate stuck', () {
    pause.pointerUp(99);

    expect(pause.isPaused, isFalse);

    pause.pointerDown(1, Offset.zero);
    expect(pause.isPaused, isTrue);
  });

  test('reset clears all active pointers', () {
    pause.pointerDown(1, Offset.zero);
    pause.pointerDown(2, Offset.zero);

    pause.reset();

    expect(pause.isPaused, isFalse);
  });
}

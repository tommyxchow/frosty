import 'package:flutter/gestures.dart';

/// Decides whether the chat message list should hold buffered messages back
/// because the user is *holding* a message (a long-press candidate).
///
/// Flushing buffered messages grows the reverse list and pushes the pressed
/// message up and out of the build range, which disposes its gesture recognizer
/// mid-press and cancels the long-press. Freezing the list while a finger rests
/// on a message keeps it under the finger so the press lands.
///
/// Crucially, the freeze applies *only to a stationary finger*. The moment a
/// pointer travels past [kTouchSlop] it's a scroll, not a hold, so the chat
/// resumes flowing — otherwise freezing then batch-releasing mid-scroll makes
/// scrolling feel like it gets cancelled. This is the same threshold the
/// long-press recognizer uses to tell a hold from a drag.
///
/// Tracks pointers individually so multi-touch resolves correctly: the chat
/// only resumes once every stationary pointer has lifted or started moving.
class ChatInteractionPause {
  /// Down position of each active pointer, by pointer id.
  final _origins = <int, Offset>{};

  /// Pointers that have moved past the slop this gesture — i.e. are scrolling.
  /// Once a pointer is here it stays until it lifts, so a drag never flips back
  /// to a hold mid-gesture.
  final _scrolling = <int>{};

  /// Whether any pointer is down and still stationary (a long-press candidate).
  bool get isPaused => _origins.length > _scrolling.length;

  /// Register a pointer touching down at [position].
  void pointerDown(int pointer, Offset position) {
    _origins[pointer] = position;
  }

  /// Update a pointer's position; flags it as scrolling once it passes the slop.
  void pointerMove(int pointer, Offset position) {
    final origin = _origins[pointer];
    if (origin == null) return;
    if ((position - origin).distance > kTouchSlop) _scrolling.add(pointer);
  }

  /// Register a pointer lifting off (or being cancelled).
  void pointerUp(int pointer) {
    _origins.remove(pointer);
    _scrolling.remove(pointer);
  }

  /// Force-clear all active pointers (e.g. on dispose or tab switch).
  void reset() {
    _origins.clear();
    _scrolling.clear();
  }
}

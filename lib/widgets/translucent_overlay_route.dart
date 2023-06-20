import 'package:flutter/material.dart';

class TranslucentOverlayRoute<T> extends TransitionRoute<T> {
  final Duration _transitionDuration;
  final WidgetBuilder builder;

  TranslucentOverlayRoute({
    required this.builder,
    Duration transitionDuration = Duration.zero,
  }) : _transitionDuration = transitionDuration;

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return [OverlayEntry(builder: builder, maintainState: true)];
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => _transitionDuration;
}

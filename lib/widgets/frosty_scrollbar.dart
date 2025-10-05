import 'package:flutter/material.dart';

/// Custom scrollbar with consistent Frosty styling across the app.
///
/// This widget wraps [RawScrollbar] with optimized defaults for appearance
/// and behavior. Use [padding] to offset the scrollbar from UI elements
/// like app bars and bottom navigation.
class FrostyScrollbar extends StatelessWidget {
  /// The scroll controller for the scrollbar.
  final ScrollController? controller;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Padding to offset the scrollbar from top/bottom UI elements.
  ///
  /// Unlike content padding, this only affects the scrollbar thumb position.
  /// Use this to prevent the scrollbar from going under app bars or nav bars.
  final EdgeInsets? padding;

  const FrostyScrollbar({
    super.key,
    this.controller,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: controller,
      thickness: 5,
      radius: const Radius.circular(2.5),
      thumbColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
      interactive: true,
      minThumbLength: 48,
      padding: padding,
      child: child,
    );
  }
}

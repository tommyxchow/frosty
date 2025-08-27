import 'dart:ui';

import 'package:flutter/material.dart';

/// Consistent blur effect configuration
class BlurConfig {
  static const double sigmaX = 16.0;
  static const double sigmaY = 16.0;

  // Theme-specific adjustments
  static const double lightModeAlpha =
      0.6; // Slightly more opaque in light mode
  static const double darkModeAlpha =
      0.3; // More opaque in dark mode for better visibility
}

/// A reusable container with consistent blur effect and background
class BlurredContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? sigmaX;
  final double? sigmaY;
  final double? backgroundAlpha;
  final bool? forceDarkMode;

  const BlurredContainer({
    super.key,
    required this.child,
    this.padding,
    this.sigmaX,
    this.sigmaY,
    this.backgroundAlpha,
    this.forceDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = forceDarkMode ?? (theme.brightness == Brightness.dark);

    // Adaptive alpha based on theme for optimal visibility
    final adaptiveAlpha = backgroundAlpha ??
        (isDark ? BlurConfig.darkModeAlpha : BlurConfig.lightModeAlpha);

    // Use dark background color if forced, otherwise use theme color
    final backgroundColor = forceDarkMode == true 
        ? Colors.black 
        : theme.scaffoldBackgroundColor;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: sigmaX ?? BlurConfig.sigmaX,
          sigmaY: sigmaY ?? BlurConfig.sigmaY,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor.withValues(
              alpha: adaptiveAlpha,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

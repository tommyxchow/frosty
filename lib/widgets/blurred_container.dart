import 'dart:ui';

import 'package:flutter/material.dart';

/// Gradient direction for the blurred container
enum GradientDirection {
  up, // Fade up (for top app bars)
  down, // Fade down (for bottom app bars)
  none, // No gradient (solid color)
}

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
  final GradientDirection gradientDirection;

  const BlurredContainer({
    super.key,
    required this.child,
    this.padding,
    this.sigmaX,
    this.sigmaY,
    this.backgroundAlpha,
    this.forceDarkMode,
    this.gradientDirection = GradientDirection.none,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = forceDarkMode ?? (theme.brightness == Brightness.dark);

    // Adaptive alpha based on theme for optimal visibility
    final adaptiveAlpha =
        backgroundAlpha ??
        (isDark ? BlurConfig.darkModeAlpha : BlurConfig.lightModeAlpha);

    // Use dark background color if forced, otherwise use theme color
    final backgroundColor = forceDarkMode == true
        ? Colors.black
        : theme.scaffoldBackgroundColor;

    // Create decoration based on gradient direction
    Decoration decoration;
    if (gradientDirection == GradientDirection.none) {
      // Solid color (original behavior)
      decoration = BoxDecoration(
        color: backgroundColor.withValues(alpha: adaptiveAlpha),
      );
    } else {
      List<Color> colors;
      Alignment begin;
      Alignment end;

      List<double> stops;

      if (gradientDirection == GradientDirection.up) {
        // Fade up: 100% opacity at TOP, 0% at bottom
        colors = [
          backgroundColor,
          backgroundColor.withValues(alpha: 0.7),
          backgroundColor.withValues(alpha: 0.3),
          backgroundColor.withValues(alpha: 0.0),
        ];
        stops = [0.0, 0.3, 0.7, 1.0];
        begin = Alignment.topCenter;
        end = Alignment.bottomCenter;
      } else {
        // Fade down: 0% at top, 100% opacity at BOTTOM
        colors = [
          backgroundColor.withValues(alpha: 0.0),
          backgroundColor.withValues(alpha: 0.3),
          backgroundColor.withValues(alpha: 0.7),
          backgroundColor,
        ];
        stops = [0.0, 0.3, 0.7, 1.0];
        begin = Alignment.topCenter;
        end = Alignment.bottomCenter;
      }

      decoration = BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ),
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: sigmaX ?? BlurConfig.sigmaX,
          sigmaY: sigmaY ?? BlurConfig.sigmaY,
        ),
        child: Container(
          padding: padding,
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }
}

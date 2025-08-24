import 'dart:ui';

import 'package:flutter/material.dart';

/// Consistent blur effect configuration
class BlurConfig {
  static const double sigmaX = 16.0;
  static const double sigmaY = 16.0;
  static const double backgroundAlpha = 0.6;
}

/// A reusable container with consistent blur effect and background
class BlurredContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? sigmaX;
  final double? sigmaY;
  final double? backgroundAlpha;

  const BlurredContainer({
    super.key,
    required this.child,
    this.padding,
    this.sigmaX,
    this.sigmaY,
    this.backgroundAlpha,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: sigmaX ?? BlurConfig.sigmaX,
          sigmaY: sigmaY ?? BlurConfig.sigmaY,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(
              alpha: backgroundAlpha ?? BlurConfig.backgroundAlpha,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

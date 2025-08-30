import 'package:flutter/material.dart';

/// Utility class for handling device orientation logic across the app.
///
/// This centralizes orientation-related checks and provides convenient helpers
/// for common layout decisions based on orientation.
class OrientationUtils {
  /// Gets the current orientation from the given context
  static Orientation getCurrentOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Returns true if the current orientation is portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Returns true if the current orientation is landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}

/// Extension methods for BuildContext to make orientation checks more convenient
extension OrientationContextExtensions on BuildContext {
  /// Gets the current orientation
  Orientation get orientation => OrientationUtils.getCurrentOrientation(this);

  /// Returns true if currently in portrait orientation
  bool get isPortrait => OrientationUtils.isPortrait(this);

  /// Returns true if currently in landscape orientation
  bool get isLandscape => OrientationUtils.isLandscape(this);
}

import 'dart:io';
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:frosty/constants.dart';

// --- Contrast helpers ---
double _linearize(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _relativeLuminance(Color c) {
  final r = _linearize(c.r);
  final g = _linearize(c.g);
  final b = _linearize(c.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color a, Color b) {
  final l1 = _relativeLuminance(a);
  final l2 = _relativeLuminance(b);
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

/// Adjusts [color] just enough to reach [targetContrast] on the app's background.
/// Defaults to Theme.of(context).scaffoldBackgroundColor; if transparent, falls
/// back to theme.colorScheme.surface.
///
/// For normal-size text use 4.5; for large/bold labels you can pass 3.0.
Color adjustChatNameColor(
  BuildContext context,
  Color color, {
  Color? background,
  double targetContrast = 4.5,
}) {
  final theme = Theme.of(context);

  // Pick background: scaffoldBackgroundColor -> surface (if scaffold is transparent).
  Color bg = background ?? theme.scaffoldBackgroundColor;
  if (bg.a == 0.0) {
    // Some themes leave scaffold transparent and paint surfaces; use surface then.
    bg = theme.colorScheme.surface;
  }

  if (_contrastRatio(color, bg) >= targetContrast) return color;

  final hsl0 = HSLColor.fromColor(color);
  final bool darkBg = _relativeLuminance(bg) < 0.5;

  // Binary search lightness toward the needed extreme with gentle sat easing.
  double lo = darkBg ? hsl0.lightness : 0.0;
  double hi = darkBg ? 1.0 : hsl0.lightness;
  double bestL = hsl0.lightness;

  for (int i = 0; i < 16; i++) {
    final mid = (lo + hi) / 2.0;
    final t = (mid - 0.5).abs() * 2; // 0..1 near ends
    final easedSat = (hsl0.saturation * (1 - 0.25 * t * t)).clamp(0.0, 1.0);
    final candidate = hsl0
        .withLightness(mid)
        .withSaturation(easedSat)
        .toColor();

    if (_contrastRatio(candidate, bg) >= targetContrast) {
      bestL = mid;
      if (darkBg) {
        hi = mid; // go brighter, but keep minimal change
      } else {
        lo = mid; // go darker
      }
    } else {
      if (darkBg) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
  }

  final t = (bestL - 0.5).abs() * 2;
  final easedSat = (hsl0.saturation * (1 - 0.25 * t * t)).clamp(0.0, 1.0);
  return hsl0.withLightness(bestL).withSaturation(easedSat).toColor();
}

String getReadableName(String displayName, String username) {
  if (!regexEnglish.hasMatch(displayName)) {
    return '$displayName ($username)';
  }

  return displayName;
}

var _isIPad = false;

bool isIPad() {
  return _isIPad;
}

Future<void> initUtils() async {
  // Determine whether the device is an iPad or not.
  if (Platform.isIOS) {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.iosInfo;
    if (info.model.toLowerCase().contains('ipad')) {
      _isIPad = true;
    }
  }
}

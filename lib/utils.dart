import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:frosty/constants.dart';

String getReadableName(String displayName, String username) {
  if (!regexEnglish.hasMatch(displayName)) {
    return '$displayName ($username)';
  }

  return displayName;
}

/// Adjusts a color based on the current theme to ensure good contrast.
/// This algorithm adjusts the lightness of colors to make them more readable
/// in both light and dark themes.
Color adjustColorForTheme(Color color, Brightness brightness) {
  final hsl = HSLColor.fromColor(color);

  if (brightness == Brightness.light) {
    if (hsl.lightness >= 0.5) {
      return hsl
          .withLightness(hsl.lightness + ((0 - hsl.lightness) * 0.5))
          .toColor();
    }
  } else {
    if (hsl.lightness <= 0.5) {
      return hsl
          .withLightness(hsl.lightness + ((1 - hsl.lightness) * 0.5))
          .toColor();
    }
  }

  return color;
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

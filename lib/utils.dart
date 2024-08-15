import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:frosty/constants.dart';

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

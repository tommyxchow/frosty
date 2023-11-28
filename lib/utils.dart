import 'package:frosty/constants.dart';

String getReadableName(String displayName, String username) {
  if (!regexEnglish.hasMatch(displayName)) {
    return '$displayName ($username)';
  }

  return displayName;
}

import 'package:flutter/services.dart';

class CookieExtractor {
  static const _channel = MethodChannel('frosty/cookie_extractor');

  static Future<String?> extractTwitchAuthToken() async {
    return await _channel.invokeMethod<String>('extractTwitchAuthToken');
  }
}

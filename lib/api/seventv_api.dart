import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart' as http;

// A class for general requests.
class SevenTV {
  /// Returns a map of global 7TV emotes to their URL.
  static Future<Map<String, String>?> getEmotesGlobal() async {
    final url = Uri.parse('https://api.7tv.app/v2/emotes/global');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => Emote7TV.fromJson(emote)).toList();

      final emoteToUrl = <String, String>{};
      for (final emote in emotes) {
        emoteToUrl[emote.name] = emote.urls[3][1];
      }
      return emoteToUrl;
    } else {
      debugPrint('Failed to get global 7TV emotes. Error code: ${response.statusCode}');
    }
  }

  /// Returns a map of a channel's 7TV emotes to their URL.
  static Future<Map<String, String>?> getEmotesChannel({required String user}) async {
    final url = Uri.parse('https://api.7tv.app/v2/users/$user/emotes');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => Emote7TV.fromJson(emote)).toList();

      final emoteToUrl = <String, String>{};
      for (final emote in emotes) {
        emoteToUrl[emote.name] = emote.urls[3][1];
      }
      return emoteToUrl;
    } else {
      debugPrint('Failed to get channel 7TV emotes. Error code: ${response.statusCode}');
    }
  }
}

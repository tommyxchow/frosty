import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart' as http;

class FFZ {
  /// Returns a map of global FFZ emotes to their URL.
  static Future<Map<String, String>?> getEmotesGlobal() async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/frankerfacez/emotes/global');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => EmoteFFZ.fromJson(emote)).toList();

      final emoteToUrl = <String, String>{};
      for (final emote in emotes) {
        emoteToUrl[emote.code] = emote.images.url4x ?? emote.images.url1x;
      }

      return emoteToUrl;
    } else {
      debugPrint('Failed to get global FFZ emotes. Error code: ${response.statusCode}');
    }
  }

  /// Returns a map of a channel's FFZ emotes to their URL.
  static Future<Map<String, String>?> getEmotesChannel({required String id}) async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/frankerfacez/users/twitch/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => EmoteFFZ.fromJson(emote)).toList();

      final emoteToUrl = <String, String>{};
      for (final emote in emotes) {
        emoteToUrl[emote.code] = emote.images.url4x ?? emote.images.url1x;
      }

      return emoteToUrl;
    } else {
      debugPrint('Failed to get FFZ emotes for id: $id. Error code: ${response.statusCode}');
    }
  }
}

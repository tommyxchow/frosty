import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart' as http;

class BTTV {
  /// Returns a map of global BTTV emotes to their URL.
  static Future<Map<String, String>?> getEmotesGlobal() async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/emotes/global');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => EmoteBTTVGlobal.fromJson(emote)).toList();

      final emoteToUrl = <String, String>{};
      for (final emote in emotes) {
        emoteToUrl[emote.code] = 'https://cdn.betterttv.net/emote/${emote.id}/3x';
      }

      return emoteToUrl;
    } else {
      debugPrint('Failed to get global BTTV emotes. Error code: ${response.statusCode}');
    }
  }

  /// Returns a map of a channel's BTTV emotes to their URL.
  static Future<Map<String, String>?> getEmotesChannel({required String id}) async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/users/twitch/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final result = EmoteBTTVChannel.fromJson(decoded);

      final emoteToUrl = <String, String>{};
      for (final emote in result.channelEmotes) {
        emoteToUrl[emote.code] = 'https://cdn.betterttv.net/emote/${emote.id}/3x';
      }
      for (final emote in result.sharedEmotes) {
        emoteToUrl[emote.code] = 'https://cdn.betterttv.net/emote/${emote.id}/3x';
      }

      return emoteToUrl;
    } else {
      debugPrint('Failed to get BTTV emotes for id: $id. Error code: ${response.statusCode}');
    }
  }
}

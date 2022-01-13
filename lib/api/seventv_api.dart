import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart' as http;

// A class for general requests.
class SevenTV {
  /// Returns a map of global 7TV emotes to their URL.
  static Future<List<Emote>> getEmotesGlobal() async {
    final url = Uri.parse('https://api.7tv.app/v2/emotes/global');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => Emote7TV.fromJson(emote));

      return emotes.map((emote) => Emote.from7TV(emote, EmoteType.sevenTvGlobal)).toList();
    } else {
      debugPrint('Failed to get global 7TV emotes. Error code: ${response.statusCode}');
      return [];
    }
  }

  /// Returns a map of a channel's 7TV emotes to their URL.
  static Future<List<Emote>> getEmotesChannel({required String user}) async {
    final url = Uri.parse('https://api.7tv.app/v2/users/$user/emotes');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => Emote7TV.fromJson(emote));

      return emotes.map((emote) => Emote.from7TV(emote, EmoteType.sevenTvChannel)).toList();
    } else {
      debugPrint('Failed to get channel 7TV emotes. Error code: ${response.statusCode}');
      return [];
    }
  }

  static Future<Map<String, List<Badge>>?> getBadges() async {
    final url = Uri.parse('https://api.7tv.app/v2/badges?user_identifier=twitch_id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['badges'] as List;
      final badges = decoded.map((emote) => BadgeInfo7TV.fromJson(emote));

      final result = <String, List<Badge>>{};
      for (final badge in badges) {
        for (final userId in badge.users) {
          final entry = result[userId];
          final normalBadge = Badge.from7TV(badge);
          if (entry == null) {
            result[userId] = [normalBadge];
          } else {
            entry.add(normalBadge);
          }
        }
      }

      return result;
    } else {
      debugPrint('Failed to get channel 7TV emotes. Error code: ${response.statusCode}');
    }
  }
}

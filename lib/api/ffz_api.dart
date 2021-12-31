import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart' as http;

class FFZ {
  /// Returns a map of global FFZ emotes to their URL.
  static Future<List<Emote>> getEmotesGlobal() async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/frankerfacez/emotes/global');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => EmoteFFZ.fromJson(emote));

      return emotes.map((emote) => Emote.fromFFZ(emote, EmoteType.ffzGlobal)).toList();
    } else {
      debugPrint('Failed to get global FFZ emotes. Error code: ${response.statusCode}');
      return [];
    }
  }

  /// Returns a map of a channel's FFZ emotes to their URL.
  static Future<List<Emote>> getEmotesChannel({required String id}) async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/frankerfacez/users/twitch/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => EmoteFFZ.fromJson(emote));

      return emotes.map((emote) => Emote.fromFFZ(emote, EmoteType.ffzChannel)).toList();
    } else {
      debugPrint('Failed to get FFZ emotes for id: $id. Error code: ${response.statusCode}');
      return [];
    }
  }

  static Future<Map<String, List<BadgeInfoFFZ>>?> getBadges() async {
    final url = Uri.parse('https://api.frankerfacez.com/v1/badges');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final badges = decoded['badges'] as List;
      final users = decoded['users'];

      final badgeObjects = badges.map((badge) => BadgeInfoFFZ.fromJson(badge)).toList();

      final result = <String, List<BadgeInfoFFZ>>{};
      final developers = users['1'] as List;
      final bots = users['2'] as List;
      final supporters = users['3'] as List;

      for (var username in developers) {
        final entry = result[username];
        if (entry != null) {
          entry.add(badgeObjects[0]);
        } else {
          result[username] = [badgeObjects[0]];
        }
      }
      for (var username in bots) {
        final entry = result[username];
        if (entry != null) {
          entry.add(badgeObjects[1]);
        } else {
          result[username] = [badgeObjects[1]];
        }
      }
      for (var username in supporters) {
        final entry = result[username];
        if (entry != null) {
          entry.add(badgeObjects[2]);
        } else {
          result[username] = [badgeObjects[2]];
        }
      }

      return result;
    }
    debugPrint('Failed to get FFZ badges');
  }
}

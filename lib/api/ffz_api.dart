import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

class FFZ {
  /// Returns a map of global FFZ emotes to their URL.
  static Future<List<Emote>> getEmotesGlobal() async {
    final url = Uri.parse('https://api.frankerfacez.com/v1/set/global');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final defaultSets = decoded['default_sets'] as List;

      final emotes = <EmoteFFZ>[];
      for (final setId in defaultSets) {
        final emoticons = decoded['sets'][setId.toString()]['emoticons'] as List;
        emotes.addAll(emoticons.map((emote) => EmoteFFZ.fromJson(emote)));
      }

      return emotes.map((emote) => Emote.fromFFZ(emote, EmoteType.ffzGlobal)).toList();
    } else {
      debugPrint('Failed to get global FFZ emotes. Error code: ${response.statusCode}');
      return [];
    }
  }

  /// Returns a channel's FFZ room info including custom badges and emote used.
  static Future<Tuple2<RoomFFZ, List<Emote>>?> getRoomInfo({required String name}) async {
    final url = Uri.parse('https://api.frankerfacez.com/v1/room/$name');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final roomInfo = RoomFFZ.fromJson(decoded['room']);
      final emoticons = decoded['sets'][roomInfo.set.toString()]['emoticons'] as List;

      final emotes = emoticons.map((emote) => EmoteFFZ.fromJson(emote));

      return Tuple2(roomInfo, emotes.map((emote) => Emote.fromFFZ(emote, EmoteType.ffzChannel)).toList());
    } else {
      debugPrint('Failed to get FFZ emotes for id: $name. Error code: ${response.statusCode}');
    }
  }

  static Future<Map<String, List<BadgeInfoFFZ>>?> getBadges() async {
    final url = Uri.parse('https://api.frankerfacez.com/v1/badges/ids');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final badges = decoded['badges'] as List;
      final badgeObjects = badges.map((badge) => BadgeInfoFFZ.fromJson(badge)).toList();

      final result = <String, List<BadgeInfoFFZ>>{};

      for (final badge in badgeObjects.reversed) {
        for (final userId in decoded['users'][badge.id.toString()]) {
          final entry = result[userId.toString()];
          if (entry == null) {
            result[userId.toString()] = [badge];
          } else {
            entry.add(badge);
          }
        }
      }

      return result;
    }
    debugPrint('Failed to get FFZ badges');
  }
}

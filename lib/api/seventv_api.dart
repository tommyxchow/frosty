import 'dart:convert';

import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart';

// A class for general requests.
class SevenTVAPI {
  final Client _client;

  SevenTVAPI(this._client);

  /// Returns a map of global 7TV emotes to their URL.
  Future<List<Emote>> getEmotesGlobal() async {
    final url = Uri.parse('https://api.7tv.app/v2/emotes/global');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => Emote7TV.fromJson(emote));

      return emotes.map((emote) => Emote.from7TV(emote, EmoteType.sevenTvGlobal)).toList();
    } else {
      throw Exception('Failed to get global 7TV emotes.');
    }
  }

  /// Returns a map of a channel's 7TV emotes to their URL.
  Future<List<Emote>> getEmotesChannel({required String user}) async {
    final url = Uri.parse('https://api.7tv.app/v2/users/$user/emotes');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => Emote7TV.fromJson(emote));

      return emotes.map((emote) => Emote.from7TV(emote, EmoteType.sevenTvChannel)).toList();
    } else {
      throw Exception('Failed to get channel 7TV emotes.');
    }
  }

  Future<Map<String, List<Badge>>> getBadges() async {
    final url = Uri.parse('https://api.7tv.app/v2/badges?user_identifier=twitch_id');

    final response = await _client.get(url);
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
      throw Exception('Failed to get 7TV badges.');
    }
  }
}

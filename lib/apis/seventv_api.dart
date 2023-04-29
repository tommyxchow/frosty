import 'dart:convert';

import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart';

/// The 7TV service for making API calls.
class SevenTVApi {
  final Client _client;

  const SevenTVApi(this._client);

  /// Returns a map of global 7TV emotes to their URL.
  Future<List<Emote>> getEmotesGlobal() async {
    final url = Uri.parse('https://api.7tv.app/v2/emotes/global');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => Emote7TV.fromJson(emote));

      return emotes
          .map((emote) => Emote.from7TV(emote, EmoteType.sevenTVGlobal))
          .toList();
    } else {
      return Future.error('Failed to get 7TV global emotes');
    }
  }

  /// Returns a map of a channel's 7TV emotes to their URL.
  Future<List<Emote>> getEmotesChannel({required String id}) async {
    final url = Uri.parse('https://api.7tv.app/v2/users/$id/emotes');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => Emote7TV.fromJson(emote));

      return emotes
          .map((emote) => Emote.from7TV(emote, EmoteType.sevenTVChannel))
          .toList();
    } else {
      return Future.error('Failed to get 7TV channel emotes');
    }
  }

  /// Returns a map of user IDS to a list of their 7TV badges.
  Future<Map<String, List<ChatBadge>>> getBadges() async {
    final url =
        Uri.parse('https://api.7tv.app/v2/badges?user_identifier=twitch_id');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['badges'] as List;
      final badges = decoded.map((emote) => BadgeInfo7TV.fromJson(emote));

      final result = <String, List<ChatBadge>>{};
      for (final badge in badges) {
        for (final userId in badge.users) {
          final entry = result[userId];
          final normalBadge = ChatBadge.from7TV(badge);
          if (entry == null) {
            result[userId] = [normalBadge];
          } else {
            entry.add(normalBadge);
          }
        }
      }

      return result;
    } else {
      return Future.error('Failed to get 7TV badges');
    }
  }
}

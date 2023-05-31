import 'dart:convert';

import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart';

/// The FFZ service for making API calls.
class FFZApi {
  final Client _client;

  const FFZApi(this._client);

  /// Returns a map of global FFZ emotes to their URL.
  Future<List<Emote>> getEmotesGlobal() async {
    final url = Uri.parse('https://api.frankerfacez.com/v1/set/global');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final defaultSets = decoded['default_sets'] as List;

      final emotes = <EmoteFFZ>[];
      for (final setId in defaultSets) {
        final emoticons =
            decoded['sets'][setId.toString()]['emoticons'] as List;
        emotes.addAll(emoticons.map((emote) => EmoteFFZ.fromJson(emote)));
      }

      return emotes
          .map((emote) => Emote.fromFFZ(emote, EmoteType.ffzGlobal))
          .toList();
    } else {
      return Future.error('Failed to get FFZ global emotes');
    }
  }

  /// Returns a channel's FFZ room info including custom badges and emote used.
  Future<(RoomFFZ, List<Emote>)> getRoomInfo({required String id}) async {
    final url = Uri.parse('https://api.frankerfacez.com/v1/room/id/$id');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final roomInfo = RoomFFZ.fromJson(decoded['room']);
      final emoticons =
          decoded['sets'][roomInfo.set.toString()]['emoticons'] as List;

      final emotes = emoticons.map((emote) => EmoteFFZ.fromJson(emote));

      return (
        roomInfo,
        emotes
            .map((emote) => Emote.fromFFZ(emote, EmoteType.ffzChannel))
            .toList()
      );
    } else {
      return Future.error('Failed to get FFZ room info');
    }
  }

  /// Returns a map of badges user IDs to a list of their FFZ badges.
  Future<Map<String, List<ChatBadge>>> getBadges() async {
    final url = Uri.parse('https://api.frankerfacez.com/v1/badges/ids');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final badges = decoded['badges'] as List;
      final badgeObjects =
          badges.map((badge) => BadgeInfoFFZ.fromJson(badge)).toList();

      final result = <String, List<ChatBadge>>{};
      for (final badge in badgeObjects.reversed) {
        for (final userId in decoded['users'][badge.id.toString()]) {
          final entry = result[userId.toString()];
          final normalBadge = ChatBadge.fromFFZ(badge);
          if (entry == null) {
            result[userId.toString()] = [normalBadge];
          } else {
            entry.add(normalBadge);
          }
        }
      }

      return result;
    } else {
      return Future.error('Failed to get FFZ badges');
    }
  }
}

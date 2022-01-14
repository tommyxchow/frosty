import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart';

class BTTVApi {
  final Client _client;

  BTTVApi(this._client);

  /// Returns a map of global BTTV emotes to their URL.
  Future<List<Emote>> getEmotesGlobal() async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/emotes/global');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      final emotes = decoded.map((emote) => EmoteBTTV.fromJson(emote)).toList();

      return emotes.map((emote) => Emote.fromBTTV(emote, EmoteType.bttvGlobal)).toList();
    } else {
      debugPrint('Failed to get global BTTV emotes. Error code: ${response.statusCode}');
      return [];
    }
  }

  /// Returns a map of a channel's BTTV emotes to their URL.
  Future<List<Emote>> getEmotesChannel({required String id}) async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/users/twitch/$id');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final result = EmoteBTTVChannel.fromJson(decoded);

      final emoteToUrl = <Emote>[];
      emoteToUrl.addAll(result.channelEmotes.map((emote) => Emote.fromBTTV(emote, EmoteType.bttvChannel)));
      emoteToUrl.addAll(result.sharedEmotes.map((emote) => Emote.fromBTTV(emote, EmoteType.bttvShared)));

      return emoteToUrl;
    } else {
      debugPrint('Failed to get BTTV emotes for id: $id. Error code: ${response.statusCode}');
      return [];
    }
  }

  Future<Map<String, Badge>?> getBadges() async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/badges');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final badges = jsonDecode(response.body) as List;

      final badgeObjects = badges.map((badge) => BadgeInfoBTTV.fromJson(badge)).toList();

      return {for (final badge in badgeObjects) badge.providerId: Badge.fromBTTV(badge)};
    }
    debugPrint('Failed to get FFZ badges');
  }
}

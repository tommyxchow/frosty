import 'dart:convert';

import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart';

/// The 7TV service for making API calls.
class SevenTVApi {
  final Client _client;

  const SevenTVApi(this._client);

  /// Returns a map of global 7TV emotes to their URL.
  Future<List<Emote>> getEmotesGlobal() async {
    final url = Uri.parse('https://7tv.io/v3/emote-sets/global');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['emotes'] as List;
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
    final url = Uri.parse('https://7tv.io/v3/users/twitch/$id');

    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['emote_set']['emotes'] as List;
      final emotes = decoded.map((emote) => Emote7TV.fromJson(emote));

      return emotes
          .map((emote) => Emote.from7TV(emote, EmoteType.sevenTVChannel))
          .toList();
    } else {
      return Future.error('Failed to get 7TV channel emotes');
    }
  }
}

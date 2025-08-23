import 'package:dio/dio.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/models/emotes.dart';

/// The 7TV service for making API calls.
class SevenTVApi extends BaseApiClient {
  SevenTVApi(Dio dio) : super(dio, 'https://7tv.io/v3');

  /// Returns a map of global 7TV emotes to their URL.
  Future<List<Emote>> getEmotesGlobal() async {
    final data = await get<JsonMap>('/emote-sets/global');

    final decoded = data['emotes'] as JsonList;
    final emotes = decoded.map((emote) => Emote7TV.fromJson(emote));

    return emotes
        .map((emote) => Emote.from7TV(emote, EmoteType.sevenTVGlobal))
        .toList();
  }

  /// Returns a tuple containing the emote set ID and a map of a channel's 7TV
  /// emotes to their URL.
  Future<(String, List<Emote>)> getEmotesChannel({required String id}) async {
    final data = await get<JsonMap>('/users/twitch/$id');

    final emoteSetId = data['emote_set']['id'] as String;
    final emotes = (data['emote_set']['emotes'] as JsonList)
        .map((emote) => Emote7TV.fromJson(emote));

    return (
      emoteSetId,
      emotes
          .map((emote) => Emote.from7TV(emote, EmoteType.sevenTVChannel))
          .where((emote) => emote.url.isNotEmpty)
          .toList()
    );
  }
}

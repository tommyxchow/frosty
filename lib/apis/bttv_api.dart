import 'package:dio/dio.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';

/// The BTTV service for making API calls.
class BTTVApi extends BaseApiClient {
  BTTVApi(Dio dio) : super(dio, 'https://api.betterttv.net/3/cached');

  /// Returns a map of global BTTV emotes to their URL.
  Future<List<Emote>> getEmotesGlobal() async {
    final data = await get<JsonList>('/emotes/global');

    final emotes = data.map((emote) => EmoteBTTV.fromJson(emote)).toList();

    return emotes
        .map((emote) => Emote.fromBTTV(emote, EmoteType.bttvGlobal))
        .toList();
  }

  /// Returns a map of a channel's BTTV emotes to their URL.
  Future<List<Emote>> getEmotesChannel({required String id}) async {
    final data = await get<JsonMap>('/users/twitch/$id');

    final result = EmoteBTTVChannel.fromJson(data);

    final emoteToUrl = <Emote>[];
    emoteToUrl.addAll(
      result.channelEmotes
          .map((emote) => Emote.fromBTTV(emote, EmoteType.bttvChannel)),
    );
    emoteToUrl.addAll(
      result.sharedEmotes
          .map((emote) => Emote.fromBTTV(emote, EmoteType.bttvShared)),
    );

    return emoteToUrl;
  }

  /// Returns a map of username to their BTTV badge.
  Future<Map<String, ChatBadge>> getBadges() async {
    final data = await get<JsonList>('/badges');

    final badgeObjects =
        data.map((badge) => BadgeInfoBTTV.fromJson(badge)).toList();

    return {
      for (final badge in badgeObjects)
        badge.providerId: ChatBadge.fromBTTV(badge),
    };
  }
}

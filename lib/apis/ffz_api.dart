import 'package:dio/dio.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';

/// The FFZ service for making API calls.
class FFZApi extends BaseApiClient {
  FFZApi(Dio dio) : super(dio, 'https://api.frankerfacez.com/v1');

  /// Returns a map of global FFZ emotes to their URL.
  Future<List<Emote>> getEmotesGlobal() async {
    final data = await get<JsonMap>('/set/global');

    final defaultSets = data['default_sets'] as JsonList;

    final emotes = <EmoteFFZ>[];
    for (final setId in defaultSets) {
      final emoticons = data['sets'][setId.toString()]['emoticons'] as JsonList;
      emotes.addAll(emoticons.map((emote) => EmoteFFZ.fromJson(emote)));
    }

    return emotes
        .map((emote) => Emote.fromFFZ(emote, EmoteType.ffzGlobal))
        .toList();
  }

  /// Returns a channel's FFZ room info including custom badges and emote used.
  Future<(RoomFFZ, List<Emote>)> getRoomInfo({required String id}) async {
    final data = await get<JsonMap>('/room/id/$id');

    final roomInfo = RoomFFZ.fromJson(data['room']);
    final emoticons =
        data['sets'][roomInfo.set.toString()]['emoticons'] as JsonList;

    final emotes = emoticons.map((emote) => EmoteFFZ.fromJson(emote));

    return (
      roomInfo,
      emotes.map((emote) => Emote.fromFFZ(emote, EmoteType.ffzChannel)).toList()
    );
  }

  /// Returns a map of badges user IDs to a list of their FFZ badges.
  Future<Map<String, List<ChatBadge>>> getBadges() async {
    final data = await get<JsonMap>('/badges/ids');

    final badges = data['badges'] as JsonList;
    final badgeObjects =
        badges.map((badge) => BadgeInfoFFZ.fromJson(badge)).toList();

    final result = <String, List<ChatBadge>>{};
    for (final badge in badgeObjects.reversed) {
      for (final userId in data['users'][badge.id.toString()]) {
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
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/followed_channel.dart';
import 'package:frosty/models/shared_chat_session.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/models/user.dart';

/// The Twitch service for making API calls.
class TwitchApi extends BaseApiClient {
  static const String _helixBaseUrl = 'https://api.twitch.tv/helix';
  static const String _oauthBaseUrl = 'https://id.twitch.tv/oauth2';
  static const String _recentMessagesUrl =
      'https://recent-messages.robotty.de/api/v2';

  TwitchApi(Dio dio) : super(dio, _helixBaseUrl);

  /// Returns a list of all Twitch global emotes.
  Future<List<Emote>> getEmotesGlobal() async {
    final data = await get<JsonMap>('/chat/emotes/global');

    final decoded = data['data'] as JsonList;
    final emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

    return emotes
        .map((emote) => Emote.fromTwitch(emote, EmoteType.twitchGlobal))
        .toList();
  }

  /// Returns a list of a channel's Twitch emotes given their [id].
  Future<List<Emote>> getEmotesChannel({
    required String id,
  }) async {
    final data = await get<JsonMap>(
      '/chat/emotes',
      queryParameters: {'broadcaster_id': id},
    );

    final decoded = data['data'] as JsonList;
    final emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

    return emotes.map((emote) {
      switch (emote.emoteType) {
        case 'bitstier':
          return Emote.fromTwitch(emote, EmoteType.twitchBits);
        case 'follower':
          return Emote.fromTwitch(emote, EmoteType.twitchFollower);
        case 'subscriptions':
          return Emote.fromTwitch(emote, EmoteType.twitchChannel);
        default:
          return Emote.fromTwitch(emote, EmoteType.twitchChannel);
      }
    }).toList();
  }

  /// Returns a list of Twitch emotes under the provided [setId].
  Future<List<Emote>> getEmotesSets({
    required String setId,
  }) async {
    final data = await get<JsonMap>(
      '/chat/emotes/set',
      queryParameters: {'emote_set_id': setId},
    );

    final decoded = data['data'] as JsonList;
    final emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

    return emotes.map((emote) {
      switch (emote.emoteType) {
        case 'globals':
        case 'smilies':
          return Emote.fromTwitch(emote, EmoteType.twitchGlobal);
        case 'subscriptions':
          return Emote.fromTwitch(emote, EmoteType.twitchSub);
        default:
          return Emote.fromTwitch(emote, EmoteType.twitchUnlocked);
      }
    }).toList();
  }

  /// Returns a map of global Twitch badges to their [Emote] object.
  Future<Map<String, ChatBadge>> getBadgesGlobal() async {
    final data = await get<JsonMap>('/chat/badges/global');

    final result = <String, ChatBadge>{};
    final decoded = data['data'] as JsonList;

    for (final badge in decoded) {
      final id = badge['set_id'] as String;
      final versions = badge['versions'] as JsonList;

      for (final version in versions) {
        final badgeInfo = BadgeInfoTwitch.fromJson(version);
        result['$id/${badgeInfo.id}'] = ChatBadge.fromTwitch(badgeInfo);
      }
    }

    return result;
  }

  /// Returns a map of a channel's Twitch badges to their [Emote] object.
  Future<Map<String, ChatBadge>> getBadgesChannel({
    required String id,
  }) async {
    final data = await get<JsonMap>(
      '/chat/badges',
      queryParameters: {'broadcaster_id': id},
    );

    final result = <String, ChatBadge>{};
    final decoded = data['data'] as JsonList;

    for (final badge in decoded) {
      final id = badge['set_id'] as String;
      final versions = badge['versions'] as JsonList;

      for (final version in versions) {
        final badgeInfo = BadgeInfoTwitch.fromJson(version);
        result['$id/${badgeInfo.id}'] = ChatBadge.fromTwitch(badgeInfo);
      }
    }

    return result;
  }

  /// Returns the user's info given their token.
  Future<UserTwitch> getUserInfo() async {
    final data = await get<JsonMap>('/users');

    final userData = data['data'] as JsonList;
    return UserTwitch.fromJson(userData.first);
  }

  /// Returns a token for an anonymous user.
  Future<String> getDefaultToken() async {
    // Use custom base URL for OAuth
    final data = await post<JsonMap>(
      '$_oauthBaseUrl/token',
      queryParameters: {
        'client_id': clientId,
        'client_secret': secret,
        'grant_type': 'client_credentials',
      },
    );

    return data['access_token'] as String;
  }

  /// Returns a bool indicating the validity of the given token.
  Future<bool> validateToken({required String token}) async {
    try {
      await get<JsonMap>(
        '$_oauthBaseUrl/validate',
        headers: {'Authorization': 'Bearer $token'},
      );
      return true;
    } on ApiException {
      return false;
    }
  }

  /// Returns a [StreamsTwitch] object that contains the top 20 streams and a cursor for further requests.
  Future<StreamsTwitch> getTopStreams({
    String? cursor,
  }) async {
    final data = await get<JsonMap>(
      '/streams',
      queryParameters: cursor != null ? {'after': cursor} : null,
    );

    return StreamsTwitch.fromJson(data);
  }

  /// Returns a [StreamsTwitch] object that contains the given user ID's top 20 followed streams and a cursor for further requests.
  Future<StreamsTwitch> getFollowedStreams({
    required String id,
    String? cursor,
  }) async {
    final queryParams = {'user_id': id};
    if (cursor != null) queryParams['after'] = cursor;

    final data = await get<JsonMap>(
      '/streams/followed',
      queryParameters: queryParams,
    );

    return StreamsTwitch.fromJson(data);
  }

  /// Returns a [FollowedChannels] object containing all followed channels (including offline ones) for the given user ID.
  Future<FollowedChannels> getFollowedChannels({
    required String userId,
    String? cursor,
  }) async {
    final queryParams = {'user_id': userId, 'first': '20'};
    if (cursor != null) queryParams['after'] = cursor;

    final data = await get<JsonMap>(
      '/channels/followed',
      queryParameters: queryParams,
    );

    return FollowedChannels.fromJson(data);
  }

  /// Returns a [StreamsTwitch] object that contains the list of streams under the given game/category ID.
  Future<StreamsTwitch> getStreamsUnderCategory({
    required String gameId,
    String? cursor,
  }) async {
    final queryParams = {'game_id': gameId};
    if (cursor != null) queryParams['after'] = cursor;

    final data = await get<JsonMap>(
      '/streams',
      queryParameters: queryParams,
    );

    return StreamsTwitch.fromJson(data);
  }

  /// Returns a [StreamTwitch] object containing the stream info associated with the given [userLogin].
  Future<StreamTwitch> getStream({
    required String userLogin,
  }) async {
    final data = await get<JsonMap>(
      '/streams',
      queryParameters: {'user_login': userLogin},
    );

    final streamData = data['data'] as JsonList;
    if (streamData.isNotEmpty) {
      return StreamTwitch.fromJson(streamData.first);
    } else {
      throw ApiException('$userLogin is offline', 404);
    }
  }

  Future<StreamsTwitch> getStreamsByIds({
    required List<String> userIds,
  }) async {
    // Create query string manually for multiple user_id parameters
    final userIdParams = userIds.map((id) => 'user_id=$id').join('&');
    final url = '/streams?$userIdParams&first=100';

    final data = await get<JsonMap>(url);

    return StreamsTwitch.fromJson(data);
  }

  /// Returns a [UserTwitch] object containing the user info associated with the given [userLogin].
  Future<UserTwitch> getUser({
    String? userLogin,
    String? id,
  }) async {
    final queryParams = <String, String>{};
    if (id != null) {
      queryParams['id'] = id;
    } else if (userLogin != null) {
      queryParams['login'] = userLogin;
    }

    final data = await get<JsonMap>(
      '/users',
      queryParameters: queryParams,
    );

    final userData = data['data'] as JsonList;
    if (userData.isNotEmpty) {
      return UserTwitch.fromJson(userData.first);
    } else {
      throw NotFoundException('User does not exist');
    }
  }

  /// Returns a [Channel] object containing a channels's info associated with the given [userId].
  Future<Channel> getChannel({
    required String userId,
  }) async {
    final data = await get<JsonMap>(
      '/channels',
      queryParameters: {'broadcaster_id': userId},
    );

    final channelData = data['data'] as JsonList;
    if (channelData.isNotEmpty) {
      return Channel.fromJson(channelData.first);
    } else {
      throw ApiException('Channel does not exist', 404);
    }
  }

  /// Returns a list of [ChannelQuery] objects closest matching the given [query].
  Future<List<ChannelQuery>> searchChannels({
    required String query,
  }) async {
    final data = await get<JsonMap>(
      '/search/channels',
      queryParameters: {'first': '8', 'query': query},
    );

    final channelData = data['data'] as JsonList;
    return channelData.map((e) => ChannelQuery.fromJson(e)).toList();
  }

  /// Returns a [CategoriesTwitch] object containing the next top 20 categories/games and a cursor for further requests.
  Future<CategoriesTwitch> getTopCategories({
    String? cursor,
  }) async {
    final data = await get<JsonMap>(
      '/games/top',
      queryParameters: cursor != null ? {'after': cursor} : null,
    );

    return CategoriesTwitch.fromJson(data);
  }

  /// Returns a [CategoriesTwitch] object containing the category info corresponding to the provided [gameId].
  Future<CategoriesTwitch> getCategory({
    required String gameId,
  }) async {
    final data = await get<JsonMap>(
      '/games',
      queryParameters: {'id': gameId},
    );

    return CategoriesTwitch.fromJson(data);
  }

  /// Returns a [CategoriesTwitch] containing up to 20 categories/games closest matching the [query] and a cursor for further requests.
  Future<CategoriesTwitch> searchCategories({
    required String query,
    String? cursor,
  }) async {
    final queryParams = {'first': '8', 'query': query};
    if (cursor != null) queryParams['after'] = cursor;

    final data = await get<JsonMap>(
      '/search/categories',
      queryParameters: queryParams,
    );

    return CategoriesTwitch.fromJson(data);
  }

  /// Returns the sub count associated with the given [userId].
  Future<int> getSubscriberCount({
    required String userId,
  }) async {
    final data = await get<JsonMap>(
      '/subscriptions',
      queryParameters: {'broadcaster_id': userId},
    );

    return data['total'] as int;
  }

  /// Returns a user's list of blocked users given their id.
  Future<List<UserBlockedTwitch>> getUserBlockedList({
    required String id,
    String? cursor,
  }) async {
    final queryParams = {'first': '100', 'broadcaster_id': id};
    if (cursor != null) queryParams['after'] = cursor;

    final data = await get<JsonMap>(
      '/users/blocks',
      queryParameters: queryParams,
    );

    final paginationCursor = data['pagination']['cursor'];
    final blockedList = data['data'] as JsonList;

    if (blockedList.isNotEmpty) {
      final result =
          blockedList.map((e) => UserBlockedTwitch.fromJson(e)).toList();

      if (paginationCursor != null) {
        // Wait a bit (150 milliseconds) before recursively calling.
        // This will prevent going over the rate limit to due a massive blocked users list.
        //
        // With the Twitch API, we can make up to 800 requests per minute.
        // Waiting 150 milliseconds between requests will cap the rate here at 400 requests per minute.
        await Future.delayed(const Duration(milliseconds: 150));
        result.addAll(
          await getUserBlockedList(
            id: id,
            cursor: paginationCursor,
          ),
        );
      }

      return result;
    } else {
      debugPrint('User does not have anyone blocked');
      return [];
    }
  }

  // Blocks the user with the given ID and returns true on success or false on failure.
  Future<bool> blockUser({
    required String userId,
  }) async {
    try {
      await put<dynamic>(
        '/users/blocks',
        queryParameters: {'target_user_id': userId},
      );
      return true; // If no exception, operation succeeded
    } on ApiException {
      return false;
    }
  }

  // Unblocks the user with the given ID and returns true on success or false on failure.
  Future<bool> unblockUser({
    required String userId,
  }) async {
    try {
      await delete<dynamic>(
        '/users/blocks',
        queryParameters: {'target_user_id': userId},
      );
      return true; // If no exception, operation succeeded
    } on ApiException {
      return false;
    }
  }

  Future<SharedChatSession?> getSharedChatSession({
    required String broadcasterId,
  }) async {
    final data = await get<JsonMap>(
      '/shared_chat/session',
      queryParameters: {'broadcaster_id': broadcasterId},
    );

    final sessionData = data['data'] as JsonList;
    if (sessionData.isEmpty) {
      return null;
    }

    return SharedChatSession.fromJson(sessionData.first);
  }

  /// Gets the color used for the user's name in chat.
  /// [userId] - The ID of the user whose chat color to get
  /// Returns the color as a hex string or empty string if no color is set.
  Future<String> getUserChatColor({
    required String userId,
  }) async {
    try {
      final data = await get<JsonMap>(
        '/chat/color',
        queryParameters: {
          'user_id': userId,
        },
      );

      final users = data['data'] as JsonList;
      if (users.isNotEmpty) {
        final user = users.first as JsonMap;
        return user['color'] as String? ?? '';
      }

      return '';
    } on ApiException {
      return '';
    }
  }

  /// Updates the color used for the user's name in chat.
  /// [userId] - The ID of the user whose chat color to update
  /// [color] - The color to use. Can be a named color (blue, blue_violet, etc.) or hex code for Turbo/Prime users
  /// Returns true on success or false on failure.
  Future<bool> updateUserChatColor({
    required String userId,
    required String color,
  }) async {
    try {
      await put<dynamic>(
        '/chat/color',
        queryParameters: {
          'user_id': userId,
          'color': color,
        },
      );
      return true; // If no exception, operation succeeded
    } on ApiException catch (e) {
      // Log the specific error for debugging
      debugPrint('Failed to update chat color: $e');
      return false;
    }
  }

  // Gets recent messages from a third-party service.
  Future<JsonList> getRecentMessages({
    required String userLogin,
  }) async {
    // Use custom base URL for third-party service
    final data = await get<JsonMap>(
      '$_recentMessagesUrl/recent-messages/$userLogin',
    );

    return data['messages'] as JsonList;
  }
}

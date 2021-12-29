import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/models/chatters.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/models/user.dart';
import 'package:http/http.dart' as http;

class Twitch {
  static Future<List<Emote>> getEmotesGlobal({required Map<String, String>? headers}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/emotes/global');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['data'] as List;
      final emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

      return emotes.map((emote) => Emote.fromTwitch(emote, EmoteType.twitchGlobal)).toList();
    } else {
      debugPrint('Failed to get global Twitch emotes. Error code: ${response.statusCode}');
      return [];
    }
  }

  /// Returns a map of a channel's Twitch emotes to their URL.
  static Future<List<Emote>> getEmotesChannel({required String id, required Map<String, String>? headers}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/emotes?broadcaster_id=$id');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['data'] as List;
      final emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

      return emotes.map((emote) => Emote.fromTwitch(emote, EmoteType.twitchChannel)).toList();
    } else {
      debugPrint('Failed to get Twitch emotes for id: $id. Error code: ${response.statusCode}');
      return [];
    }
  }

  /// Returns a map of a channel's Twitch emotes to their URL.
  static Future<List<Emote>> getEmotesSets({required String setId, required Map<String, String>? headers, sub = false}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/emotes/set?emote_set_id=$setId');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['data'] as List;
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
    } else {
      debugPrint('Failed to get Twitch emotes for set id: $setId. Error code: ${response.statusCode}');
      return [];
    }
  }

  /// Returns a map of global Twitch badges to their URL.
  static Future<Map<String, BadgeInfoTwitch>?> getBadgesGlobal() async {
    final url = Uri.parse('https://badges.twitch.tv/v1/badges/global/display');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = <String, BadgeInfoTwitch>{};

      final decoded = jsonDecode(response.body)['badge_sets'] as Map;

      // TODO: Figure out cleaner way to decode badge JSON.
      decoded.forEach(
          (id, versions) => (versions['versions'] as Map).forEach((version, badgeInfo) => result['$id/$version'] = BadgeInfoTwitch.fromJson(badgeInfo)));

      return result;
    } else {
      debugPrint('Failed to get global Twitch badges. Error code: ${response.statusCode}');
    }
  }

  /// Returns a map of a channel's Twitch badges to their URL.
  static Future<Map<String, BadgeInfoTwitch>?> getBadgesChannel({required String id}) async {
    final url = Uri.parse('https://badges.twitch.tv/v1/badges/channels/$id/display');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = <String, BadgeInfoTwitch>{};

      final decoded = jsonDecode(response.body)['badge_sets'] as Map;

      decoded.forEach(
          (id, versions) => (versions['versions'] as Map).forEach((version, badgeInfo) => result['$id/$version'] = BadgeInfoTwitch.fromJson(badgeInfo)));

      return result;
    } else {
      debugPrint('Failed to get Twitch badges for id: $id. Error code: ${response.statusCode}');
    }
  }

  /// Returns the user's info given their token (headers)
  static Future<UserTwitch?> getUserInfo({required Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse('https://api.twitch.tv/helix/users'), headers: headers);

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body)['data'] as List;

      return UserTwitch.fromJson(userData.first);
    } else {
      debugPrint('Failed to get user info');
    }
  }

  /// Returns a token for an anonymous user.
  static Future<String?> getDefaultToken() async {
    debugPrint('Getting default token...');

    final url = Uri(
      scheme: 'https',
      host: 'id.twitch.tv',
      path: '/oauth2/token',
      queryParameters: {
        'client_id': clientId,
        'client_secret': secret,
        'grant_type': 'client_credentials',
      },
    );

    final response = await http.post(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
    } else {
      debugPrint('Failed to get default token.');
    }
  }

  /// Returns the validity of the given token
  static Future<bool> validateToken({required String token}) async {
    debugPrint('Validating token...');
    final response = await http.get(
      Uri.parse('https://id.twitch.tv/oauth2/validate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      debugPrint('Token validated!');
      return true;
    }

    debugPrint('Token invalidated :(');
    return false;
  }

  /// Returns a map containing top 20 streams and a cursor for further requests.
  static Future<StreamsTwitch?> getTopStreams({required Map<String, String>? headers, String? cursor}) async {
    final Uri uri;

    if (cursor == null) {
      uri = Uri.parse('https://api.twitch.tv/helix/streams');
    } else {
      uri = Uri.parse('https://api.twitch.tv/helix/streams?after=$cursor');
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return StreamsTwitch.fromJson(decoded);
    } else {
      debugPrint('Failed to update top streams');
    }
  }

  /// Returns a map with the given user's top 20 followed streams and a cursor for further requests.
  static Future<StreamsTwitch?> getFollowedStreams({
    required String id,
    required Map<String, String>? headers,
    String? cursor,
  }) async {
    final Uri uri;

    if (cursor == null) {
      uri = Uri.parse('https://api.twitch.tv/helix/streams/followed?user_id=$id');
    } else {
      uri = Uri.parse('https://api.twitch.tv/helix/streams/followed?user_id=$id&after=$cursor');
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return StreamsTwitch.fromJson(decoded);
    } else {
      debugPrint('Failed to update followed streams');
    }
  }

  /// Returns the list of streams under the given game/category ID.
  static Future<StreamsTwitch?> getStreamsUnderGame({
    required String gameId,
    required Map<String, String>? headers,
    String? cursor,
  }) async {
    final uri = cursor == null
        ? Uri.parse('https://api.twitch.tv/helix/streams?game_id=$gameId')
        : Uri.parse('https://api.twitch.tv/helix/streams?game_id=$gameId&after=$cursor');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return StreamsTwitch.fromJson(decoded);
    } else {
      debugPrint('Failed to update game streams');
    }
  }

  static Future<int> getTotalViewersForGame({required String gameId, required Map<String, String>? headers}) async {
    String? currentCursor;
    var totalViewers = 0;

    for (var i = 0; i < 20; i++) {
      final uri = currentCursor == null
          ? Uri.parse('https://api.twitch.tv/helix/streams?first=100&game_id=$gameId')
          : Uri.parse('https://api.twitch.tv/helix/streams?first=100&game_id=$gameId&after=$currentCursor');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final streams = StreamsTwitch.fromJson(decoded);
        for (final stream in streams.data) {
          totalViewers += stream.viewerCount;
        }

        currentCursor = streams.pagination['cursor'];
        if (currentCursor == null) break;
      } else {
        debugPrint('Failed to update game streams');
      }
    }
    debugPrint(totalViewers.toString());
    return totalViewers;
  }

  /// Returns the stream info given the user login.
  static Future<StreamTwitch?> getStream({required String userLogin, required Map<String, String>? headers}) async {
    final uri = Uri.parse('https://api.twitch.tv/helix/streams?user_login=$userLogin');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;

      if (data.isEmpty) return null;

      return StreamTwitch.fromJson(data.first);
    } else {
      debugPrint('Failed to update top streams');
    }
  }

  /// Returns a user's info given their login name.
  static Future<UserTwitch?> getUser({String? userLogin, String? id, required Map<String, String>? headers}) async {
    final uri = id != null ? Uri.parse('https://api.twitch.tv/helix/users?id=$id') : Uri.parse('https://api.twitch.tv/helix/users?login=$userLogin');

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body)['data'] as List;

      if (userData.isNotEmpty) {
        return UserTwitch.fromJson(userData.first);
      } else {
        debugPrint('User does not exist');
      }
    } else {
      debugPrint('User does not exist');
    }
  }

  /// Returns a user's list of blocked users given their id.
  static Future<List<UserBlockedTwitch>> getUserBlockedList({required String id, required Map<String, String>? headers, String? cursor}) async {
    final uri = cursor == null
        ? Uri.parse('https://api.twitch.tv/helix/users/blocks?first=100&broadcaster_id=$id')
        : Uri.parse('https://api.twitch.tv/helix/users/blocks?first=100&after=$cursor&broadcaster_id=$id');

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final cursor = decoded['pagination']['cursor'];
      final blockedList = decoded['data'] as List;

      if (blockedList.isNotEmpty) {
        final result = blockedList.map((e) => UserBlockedTwitch.fromJson(e)).toList();

        if (cursor != null) {
          result.addAll(await getUserBlockedList(id: id, cursor: cursor, headers: headers));
        }

        return result;
      } else {
        debugPrint('User does not have anyone blocked');
        return [];
      }
    } else {
      debugPrint('User does not exist');
      return [];
    }
  }

  /// Returns a channels's info associated with the given ID.
  static Future<Channel?> getChannel({required String userId, required Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse('https://api.twitch.tv/helix/channels?broadcaster_id=$userId'), headers: headers);
    if (response.statusCode == 200) {
      final channelData = jsonDecode(response.body)['data'] as List;

      if (channelData.isNotEmpty) {
        return Channel.fromJson(channelData.first);
      } else {
        debugPrint('Channel does not exist');
      }
    } else {
      debugPrint('Channel does not exist');
    }
  }

  /// Returns a list of channel query objects closest matching the given query string.
  static Future<List<ChannelQuery>> searchChannels({required String query, required Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse('https://api.twitch.tv/helix/search/channels?first=8&query=$query'), headers: headers);
    if (response.statusCode == 200) {
      final channelData = jsonDecode(response.body)['data'] as List;

      return channelData.map((e) => ChannelQuery.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  /// Returns a map containing top 20 categories/games and a cursor for further requests.
  static Future<CategoriesTwitch?> getTopGames({required Map<String, String>? headers, String? cursor}) async {
    final Uri uri;

    if (cursor == null) {
      uri = Uri.parse('https://api.twitch.tv/helix/games/top');
    } else {
      uri = Uri.parse('https://api.twitch.tv/helix/games/top?after=$cursor');
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return CategoriesTwitch.fromJson(decoded);
    } else {
      debugPrint('Failed to update top games');
    }
  }

  /// Returns the sub count for a user.
  static Future<int?> getSubscriberCount({required String userId, required Map<String, String>? headers}) async {
    final uri = Uri.parse('https://api.twitch.tv/helix/subscriptions?broadcaster_id=$userId');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return decoded['total'] as int;
    } else {
      debugPrint('Failed to update top games');
    }
  }

  static Future<ChatUsers?> getChatters({required String userLogin}) async {
    final uri = Uri.parse('https://tmi.twitch.tv/group/user/$userLogin/chatters');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return ChatUsers.fromJson(decoded);
    } else {
      debugPrint('Failed to get chatters');
    }
  }
}

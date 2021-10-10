import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/user.dart';
import 'package:http/http.dart' as http;

class Twitch {
  static Future<Map<String, String>?> getEmotesGlobal({required Map<String, String>? headers}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/emotes/global');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['data'] as List;
      final List<EmoteTwitch> emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

      final emoteToUrl = <String, String>{};
      for (final emote in emotes) {
        emoteToUrl[emote.name] = 'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0';
      }

      return emoteToUrl;
    } else {
      debugPrint('Failed to get global Twitch emotes. Error code: ${response.statusCode}');
    }
  }

  /// Returns a map of a channel's Twitch emotes to their URL.
  static Future<Map<String, String>?> getEmotesChannel({required String id, required Map<String, String>? headers}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/emotes?broadcaster_id=$id');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['data'] as List;
      final List<EmoteTwitch> emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

      final emoteToUrl = <String, String>{};
      for (final emote in emotes) {
        emoteToUrl[emote.name] = 'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0';
      }

      return emoteToUrl;
    } else {
      debugPrint('Failed to get Twitch emotes for id: $id. Error code: ${response.statusCode}');
    }
  }

  /// Returns a map of global Twitch badges to their URL.
  static Future<Map<String, String>?> getBadgesGlobal({required Map<String, String>? headers}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/badges/global');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['data'] as List;
      final List<BadgesTwitch> badges = decoded.map((emote) => BadgesTwitch.fromJson(emote)).toList();

      final badgeToUrl = <String, String>{};
      for (final badge in badges) {
        for (final badgeVersion in badge.versions) {
          badgeToUrl['${badge.setId}/${badgeVersion.id}'] = badgeVersion.imageUrl4x;
        }
      }

      return badgeToUrl;
    } else {
      debugPrint('Failed to get global Twitch badges. Error code: ${response.statusCode}');
    }
  }

  /// Returns a map of a channel's Twitch badges to their URL.
  static Future<Map<String, String>?> getBadgesChannel({required String id, required Map<String, String>? headers}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/badges?broadcaster_id=$id');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body)['data'] as List;
      final List<BadgesTwitch> badges = decoded.map((emote) => BadgesTwitch.fromJson(emote)).toList();

      final badgeToUrl = <String, String>{};
      for (final badge in badges) {
        for (final badgeVersion in badge.versions) {
          badgeToUrl['${badge.setId}/${badgeVersion.id}'] = badgeVersion.imageUrl4x;
        }
      }

      return badgeToUrl;
    } else {
      debugPrint('Failed to get Twitch badges for id: $id. Error code: ${response.statusCode}');
    }
  }

  /// Returns the user's info given their token (headers)
  static Future<UserTwitch> getUserInfo({required Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse('https://api.twitch.tv/helix/users'), headers: headers);
    final userData = jsonDecode(response.body)['data'] as List;

    return UserTwitch.fromJson(userData.first);
  }

  /// Returns a token for an anonymous user.
  static Future<String> getDefaultToken() async {
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
    final defaultToken = jsonDecode(response.body)['access_token'];

    return defaultToken;
  }

  /// Returns the validity of the given token
  static Future<bool> validateToken({required String token}) async {
    debugPrint('Validating token...');
    final response = await http.get(Uri.parse('https://id.twitch.tv/oauth2/validate'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      debugPrint('Token validated!');
      return true;
    }

    debugPrint('Token invalidated :(');
    return false;
  }

  /// Returns a map with top 10 streamers and a cursor for further requests.
  static Future<Map<String, dynamic>?> getTopChannels({required Map<String, String>? headers, required String? cursor}) async {
    final Uri uri;

    if (cursor == null) {
      uri = Uri.parse('https://api.twitch.tv/helix/streams?first=10');
    } else {
      uri = Uri.parse('https://api.twitch.tv/helix/streams?first=10&after=$cursor');
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;

      return {'channels': data.map((channel) => Channel.fromJson(channel)).toList(), 'cursor': decoded['pagination']['cursor']};
    } else {
      debugPrint('Failed to update top channels');
    }
  }

  /// Returns a map with the given user's top 10 followed streamers and a cursor for further requests.
  static Future<Map<String, dynamic>?> getFollowedChannels({required String id, required Map<String, String>? headers, required String? cursor}) async {
    final Uri uri;

    if (cursor == null) {
      uri = Uri.parse('https://api.twitch.tv/helix/streams/followed?first=10&user_id=$id');
    } else {
      uri = Uri.parse('https://api.twitch.tv/helix/streams/followed?user_id=$id&first=10&after=$cursor');
    }

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as List;

      return {'channels': data.map((channel) => Channel.fromJson(channel)).toList(), 'cursor': decoded['pagination']['cursor']};
    } else {
      debugPrint('Failed to update followed channels');
    }
  }

  /// Returns a user's info given their login name.
  static Future<UserTwitch?> getUser({required String userLogin, required Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse('https://api.twitch.tv/helix/users?login=$userLogin'), headers: headers);
    final userData = jsonDecode(response.body)['data'] as List;

    if (userData.isNotEmpty) {
      return UserTwitch.fromJson(userData.first);
    } else {
      debugPrint('User does not exist');
    }
  }
}

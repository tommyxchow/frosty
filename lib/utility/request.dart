import 'dart:convert';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http/http.dart' as http;

// TODO: Notify user when a request for an asset has failed (and possibly an option to retry).

// A class for general requests.
class Request {
  /// Returns a mapping of global BTTV emotes to their URL.
  static Future<Map<String, String>> getEmotesBTTVGlobal() async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/emotes/global');
    final response = await http.get(url);
    final decoded = jsonDecode(response.body) as List;
    final List<EmoteBTTVGlobal> emotes = decoded.map((emote) => EmoteBTTVGlobal.fromJson(emote)).toList();

    final emoteToUrl = <String, String>{};

    for (var emote in emotes) {
      emoteToUrl[emote.code] = 'https://cdn.betterttv.net/emote/${emote.id}/3x';
    }
    return emoteToUrl;
  }

  /// Returns a mapping of a channel's BTTV emotes to their URL.
  static Future<Map<String, String>> getEmotesBTTVChannel({required String id}) async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/users/twitch/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final result = EmoteBTTVChannel.fromJson(decoded);

      final emoteToUrl = <String, String>{};

      for (final emote in result.channelEmotes) {
        emoteToUrl[emote.code] = 'https://cdn.betterttv.net/emote/${emote.id}/3x';
      }
      for (final emote in result.sharedEmotes) {
        emoteToUrl[emote.code] = 'https://cdn.betterttv.net/emote/${emote.id}/3x';
      }
      return emoteToUrl;
    } else {
      return {};
    }
  }

  /// Returns a mapping of global FFZ emotes to their URL.
  static Future<Map<String, String>> getEmotesFFZGlobal() async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/frankerfacez/emotes/global');
    final response = await http.get(url);
    final decoded = jsonDecode(response.body) as List;
    final List<EmoteFFZ> emotes = decoded.map((emote) => EmoteFFZ.fromJson(emote)).toList();

    final emoteToUrl = <String, String>{};

    for (var emote in emotes) {
      emoteToUrl[emote.code] = emote.images.url4x ?? emote.images.url1x;
    }
    return emoteToUrl;
  }

  /// Returns a mapping of a channel's FFZ emotes to their URL.
  static Future<Map<String, String>> getEmotesFFZChannel({required String id}) async {
    final url = Uri.parse('https://api.betterttv.net/3/cached/frankerfacez/users/twitch/$id');
    final response = await http.get(url);
    final decoded = jsonDecode(response.body) as List;
    final List<EmoteFFZ> emotes = decoded.map((emote) => EmoteFFZ.fromJson(emote)).toList();

    final emoteToUrl = <String, String>{};

    for (var emote in emotes) {
      emoteToUrl[emote.code] = emote.images.url4x ?? emote.images.url1x;
    }
    return emoteToUrl;
  }

  /// Returns a mapping of global Twitch emotes to their URL.
  static Future<Map<String, String>> getEmotesTwitchGlobal({required String token}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/emotes/global');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': const String.fromEnvironment('CLIENT_ID')};
    final response = await http.get(url, headers: headers);
    final decoded = jsonDecode(response.body)['data'] as List;
    final List<EmoteTwitch> emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

    final emoteToUrl = <String, String>{};

    for (var emote in emotes) {
      emoteToUrl[emote.name] = 'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0';
    }
    return emoteToUrl;
  }

  /// Returns a mapping of a channel's BTTV emotes to their URL.
  static Future<Map<String, String>> getEmotesTwitchChannel({required String token, required String id}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/emotes?broadcaster_id=$id');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': const String.fromEnvironment('CLIENT_ID')};
    final response = await http.get(url, headers: headers);
    final decoded = jsonDecode(response.body)['data'] as List;
    final List<EmoteTwitch> emotes = decoded.map((emote) => EmoteTwitch.fromJson(emote)).toList();

    final emoteToUrl = <String, String>{};

    for (var emote in emotes) {
      emoteToUrl[emote.name] = 'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0';
    }
    return emoteToUrl;
  }

  static Future<Map<String, String>> getBadgesTwitchGlobal({required String token}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/badges/global');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': const String.fromEnvironment('CLIENT_ID')};
    final response = await http.get(url, headers: headers);
    final decoded = jsonDecode(response.body)['data'] as List;
    final List<BadgesTwitch> badges = decoded.map((emote) => BadgesTwitch.fromJson(emote)).toList();

    final badgeToUrl = <String, String>{};

    for (final badge in badges) {
      for (final badgeVersion in badge.versions) {
        badgeToUrl['${badge.setId}/${badgeVersion.id}'] = badgeVersion.imageUrl4x;
      }
    }
    return badgeToUrl;
  }

  static Future<Map<String, String>> getBadgesTwitchChannel({required String token, required String id}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/chat/badges?broadcaster_id=$id');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': const String.fromEnvironment('CLIENT_ID')};
    final response = await http.get(url, headers: headers);
    final decoded = jsonDecode(response.body)['data'] as List;
    final List<BadgesTwitch> badges = decoded.map((emote) => BadgesTwitch.fromJson(emote)).toList();

    final badgeToUrl = <String, String>{};

    for (final badge in badges) {
      for (final badgeVersion in badge.versions) {
        badgeToUrl['${badge.setId}/${badgeVersion.id}'] = badgeVersion.imageUrl4x;
      }
    }
    return badgeToUrl;
  }
}

enum HTTPMethod { GET, POST }

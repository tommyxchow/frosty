import 'dart:convert';

import 'package:http/http.dart' as http;

class Request {
  static Future<String> getDefaultToken() async {
    final url = Uri(
      scheme: 'https',
      host: 'id.twitch.tv',
      path: '/oauth2/token',
      queryParameters: {
        'client_id': const String.fromEnvironment('CLIENT_ID'),
        'client_secret': const String.fromEnvironment('SECRET'),
        'grant_type': 'client_credentials'
      },
    );

    final response = await http.post(url);
    final decoded = jsonDecode(response.body);
    print(decoded);
    return decoded['access_token'];
  }

  static void getTopChannels({required String token}) async {
    final url = Uri.parse('https://api.twitch.tv/helix/streams?first=10');
    final headers = {'Authorization': 'Bearer $token', 'Client-Id': const String.fromEnvironment('CLIENT_ID')};
    final response = await http.get(url, headers: headers);
    final decoded = jsonDecode(response.body);
    print(decoded);
    final data = decoded['data'];
    print(data);

    //final List<EmoteBTTVGlobal> emotes = decoded.map((emote) => EmoteBTTVGlobal.fromJson(emote)).toList();
  }
}

enum HTTPMethod { GET, POST }

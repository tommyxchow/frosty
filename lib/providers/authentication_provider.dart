import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Authentication extends ChangeNotifier {
  final _storage = new FlutterSecureStorage();
  final _secret = const String.fromEnvironment('SECRET');
  final _clientId = const String.fromEnvironment('CLIENT_ID');

  var isLoggedIn = false;
  var tokenIsValid = false;

  String? token;
  Map<String, String>? authHeaders;
  UserTwitch? user;

  Authentication() {
    print('test');
    initAuth();
  }

  /// Initialize by retrieving a token if it does not already exist.
  void initAuth() async {
    debugPrint('Creating auth provider');
    token = await _storage.read(key: 'USER_TOKEN') ?? await getDefaultToken();
    authHeaders = {'Authorization': 'Bearer $token', 'Client-Id': _clientId};

    if (isLoggedIn) {
      await getUserInfo();
    }
    notifyListeners();
  }

  /// Returns a token for an anonymous user.
  Future<String> getDefaultToken() async {
    final url = Uri(
      scheme: 'https',
      host: 'id.twitch.tv',
      path: '/oauth2/token',
      queryParameters: {
        'client_id': _clientId,
        'client_secret': _secret,
        'grant_type': 'client_credentials',
      },
    );

    final response = await http.post(url);
    final token = jsonDecode(response.body)['access_token'];
    _storage.write(key: 'USER_TOKEN', value: token);
    return token;
  }

  Future<void> validateToken() async {
    final response = await http.get(Uri.parse(twitchValidateUrl), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      tokenIsValid = true;
      notifyListeners();
      return;
    }

    print('Token invalidated');
    tokenIsValid = false;
    notifyListeners();
  }

  Future<UserTwitch> getUserInfo() async {
    final response = await http.get(Uri.parse(twitchUsersUrl), headers: authHeaders);
    final userData = jsonDecode(response.body)['data'];
    return UserTwitch.fromJson(userData);
  }
}

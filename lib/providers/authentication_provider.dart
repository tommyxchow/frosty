import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';

// TODO: Fix up notifyListeners() placements.

class AuthenticationProvider extends ChangeNotifier {
  final _storage = new FlutterSecureStorage();
  final _secret = const String.fromEnvironment('SECRET');
  final _clientId = const String.fromEnvironment('CLIENT_ID');

  var isLoggedIn = false;
  var tokenIsValid = false;

  String? token;
  Map<String, String>? authHeaders;
  UserTwitch? user;

  /// Initialize by retrieving a token if it does not already exist.
  Future<void> init() async {
    // Read and set the currently stored user token, if any.
    token = await _storage.read(key: 'USER_TOKEN');

    // If the token does not exist, get the default token.
    // Otherwise, log in and get the user info.
    if (token != null) {
      isLoggedIn = true;
      authHeaders = {'Authorization': 'Bearer $token', 'Client-Id': _clientId};
      await getUserInfo();
    } else {
      await getDefaultToken();
    }

    // Set the auth headers for future requests and validate the token.
    authHeaders = {'Authorization': 'Bearer $token', 'Client-Id': _clientId};
    await validateToken();
    debugPrint('Created auth provider');
  }

  /// Returns a token for an anonymous user.
  Future<void> getDefaultToken() async {
    debugPrint('Getting default token...');
    token = await _storage.read(key: 'DEFAULT_TOKEN');

    if (token != null) return;

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
    final defaultToken = jsonDecode(response.body)['access_token'];

    await _storage.write(key: 'DEFAULT_TOKEN', value: defaultToken);

    token = defaultToken;
  }

  Future<void> validateToken() async {
    debugPrint('Validating token...');
    final response = await http.get(Uri.parse(twitchValidateUrl), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      debugPrint('Token validated!');
      tokenIsValid = true;
      return;
    }

    debugPrint('Token invalidated :(');
    tokenIsValid = false;

    notifyListeners();
  }

  Future<void> getUserInfo() async {
    final response = await http.get(Uri.parse(twitchUsersUrl), headers: authHeaders);
    final userData = jsonDecode(response.body)['data'] as List;

    user = UserTwitch.fromJson(userData.first);
  }

  Future<void> login() async {
    final loginUrl = Uri(
      scheme: 'https',
      host: 'id.twitch.tv',
      path: '/oauth2/authorize',
      queryParameters: {
        'client_id': _clientId,
        'redirect_uri': 'auth://',
        'response_type': 'token',
        'scope': 'chat:read chat:edit user:read:follows',
      },
    );

    try {
      final result = await FlutterWebAuth.authenticate(url: loginUrl.toString(), callbackUrlScheme: 'auth');

      final fragment = Uri.parse(result).fragment;

      token = fragment.substring(fragment.indexOf('=') + 1, fragment.indexOf('&'));
      await _storage.write(key: 'USER_TOKEN', value: token);

      isLoggedIn = true;
      authHeaders = {'Authorization': 'Bearer $token', 'Client-Id': _clientId};

      await getUserInfo();

      notifyListeners();
    } catch (error) {
      debugPrint('Login failed due to $error');
    }
  }

  void logout() async {
    await getDefaultToken();
    isLoggedIn = false;

    await _storage.delete(key: 'USER_TOKEN');
    debugPrint('Succesfully logged out');
    notifyListeners();
  }
}

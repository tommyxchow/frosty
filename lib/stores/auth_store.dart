import 'package:frosty/api/twitch_api.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter/foundation.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthBase with _$AuthStore;

abstract class _AuthBase with Store {
  /// Secure storage to store tokens.
  final _storage = const FlutterSecureStorage();

  /// Whether the token is valid or not.
  var _tokenIsValid = false;

  /// The current token.
  @readonly
  String? _token;

  /// The current user's info.
  @readonly
  UserTwitch? _user;

  /// Whether the user is logged in or not.
  @readonly
  var _isLoggedIn = false;

  /// Authentication headers for Twitch API requests.
  @computed
  Map<String, String> get headersTwitch => {'Authorization': 'Bearer $_token', 'Client-Id': clientId};

  /// Initialize by retrieving a token if it does not already exist.
  @action
  Future<void> init() async {
    // Read and set the currently stored user token, if any.
    _token = await _storage.read(key: 'USER_TOKEN');

    // If the token does not exist, get the default token.
    // Otherwise, get the user info and log in.
    if (_token == null) {
      // Retrieve the currently stored default token if it exists.
      _token = await _storage.read(key: 'DEFAULT_TOKEN');
      // If the token does not exist, get a new token and store it.
      if (_token == null) {
        _token = await Twitch.getDefaultToken();
        await _storage.write(key: 'DEFAULT_TOKEN', value: _token);
      }
    } else {
      _user = await Twitch.getUserInfo(headers: headersTwitch);
      _isLoggedIn = true;
    }

    // Validate the token.
    _tokenIsValid = await Twitch.validateToken(token: _token!);

    // If the token is invalid, logout.
    if (!_tokenIsValid) {
      logout();
      return;
    }
    debugPrint('Created auth provider');
  }

  /// Initiates the OAuth sign-in process and updates fields accordingly upon successful login.
  @action
  Future<void> login() async {
    // Create the OAuth sign-in URI.
    final loginUrl = Uri(
      scheme: 'https',
      host: 'id.twitch.tv',
      path: '/oauth2/authorize',
      queryParameters: {
        'client_id': clientId,
        'redirect_uri': 'auth://',
        'response_type': 'token',
        'scope': 'chat:read chat:edit user:read:follows',
      },
    );

    try {
      // Retrieve the OAuth redirect URI.
      final result = await FlutterWebAuth.authenticate(url: loginUrl.toString(), callbackUrlScheme: 'auth', preferEphemeral: true);

      // Parse the user token from the redirect URI fragment.
      final fragment = Uri.parse(result).fragment;
      _token = fragment.substring(fragment.indexOf('=') + 1, fragment.indexOf('&'));

      // Store the user token.
      await _storage.write(key: 'USER_TOKEN', value: _token);

      // Retrieve the user info and set it
      _user = await Twitch.getUserInfo(headers: headersTwitch);

      // Set the login status to logged in.
      _isLoggedIn = true;
    } catch (error) {
      debugPrint('Login failed due to $error');
    }
  }

  /// Logs out the current user and updates fields accordingly.
  @action
  Future<void> logout() async {
    // Delete the existing user token.
    await _storage.delete(key: 'USER_TOKEN');
    _token = null;

    // Clear the user info.
    _user = null;

    // Set the login status to logged out.
    _isLoggedIn = false;

    // If the default token already exists, set it.
    _token = await _storage.read(key: 'DEFAULT_TOKEN');

    // If the default token does not already exist, get the new default token and store it.
    // Else, validate the existing token.
    if (_token == null) {
      await Twitch.getDefaultToken();
      await _storage.write(key: 'DEFAULT_TOKEN', value: _token);
      _tokenIsValid = await Twitch.validateToken(token: _token!);
    } else {
      // Validate the stored token.
      _tokenIsValid = await Twitch.validateToken(token: _token!);

      // If the stored token is invalid, get a new default token and store it.
      if (!_tokenIsValid) {
        await Twitch.getDefaultToken();
        await _storage.write(key: 'DEFAULT_TOKEN', value: _token);
        _tokenIsValid = await Twitch.validateToken(token: _token!);
      }
    }

    debugPrint('Successfully logged out');
  }
}

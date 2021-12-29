import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/core/user/user_store.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthBase with _$AuthStore;

abstract class _AuthBase with Store {
  /// Secure storage to store tokens.
  final _storage = const FlutterSecureStorage();

  /// Whether the token is valid or not.
  var _tokenIsValid = false;

  /// The store containing information relevant to the current user.
  final user = UserStore();

  /// The current token.
  @readonly
  String? _token;

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
    // Otherwise, log in.
    if (_token == null) {
      // Retrieve the currently stored default token if it exists.
      _token = await _storage.read(key: 'DEFAULT_TOKEN');
      // If the token does not exist, get a new token and store it.
      if (_token == null) {
        _token = await Twitch.getDefaultToken();
        await _storage.write(key: 'DEFAULT_TOKEN', value: _token);
      }
    } else {
      // Initialize the user store.
      await user.init(headers: headersTwitch);

      if (user.details != null) _isLoggedIn = true;
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
        'scope': 'chat:read chat:edit user:read:follows user:read:blocked_users user:manage:blocked_users',
        'force_verify': 'true',
      },
    );

    try {
      // Retrieve the OAuth redirect URI.
      final result = await FlutterWebAuth.authenticate(url: loginUrl.toString(), callbackUrlScheme: 'auth');

      // Parse the user token from the redirect URI fragment.
      final fragment = Uri.parse(result).fragment;
      _token = fragment.substring(fragment.indexOf('=') + 1, fragment.indexOf('&'));

      // Store the user token.
      await _storage.write(key: 'USER_TOKEN', value: _token);

      // Initialize the user with the new token.
      user.init(headers: headersTwitch);

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
    user.dispose();

    // Set the login status to logged out.
    _isLoggedIn = false;

    // If the default token already exists, set it.
    _token = await _storage.read(key: 'DEFAULT_TOKEN');

    // If the default token does not already exist, get the new default token and store it.
    // Else, validate the existing token.
    if (_token == null) {
      _token = await Twitch.getDefaultToken();
      await _storage.write(key: 'DEFAULT_TOKEN', value: _token);
      _tokenIsValid = await Twitch.validateToken(token: _token!);
    } else {
      // Validate the stored token.
      _tokenIsValid = await Twitch.validateToken(token: _token!);

      // If the stored token is invalid, get a new default token and store it.
      if (!_tokenIsValid) {
        _token = await Twitch.getDefaultToken();
        await _storage.write(key: 'DEFAULT_TOKEN', value: _token);
        _tokenIsValid = await Twitch.validateToken(token: _token!);
      }
    }

    debugPrint('Successfully logged out');
  }
}

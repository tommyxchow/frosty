import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/core/user/user_store.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthBase with _$AuthStore;

abstract class _AuthBase with Store {
  /// Secure storage to store tokens.
  static const _storage = FlutterSecureStorage();

  /// The shared_preferences key for the default token.
  static const _defaultTokenKey = 'default_token';

  /// The shared_preferences key for the user token.
  static const _userTokenKey = 'user_token';

  final TwitchApi twitchApi;

  /// Whether the token is valid or not.
  var _tokenIsValid = false;

  /// The store containing information relevant to the current user.
  final UserStore user;

  /// The current token.
  @readonly
  String? _token;

  /// Whether the user is logged in or not.
  @readonly
  var _isLoggedIn = false;

  /// Authentication headers for Twitch API requests.
  @computed
  Map<String, String> get headersTwitch => {'Authorization': 'Bearer $_token', 'Client-Id': clientId};

  /// Error flag that will be non-null if login failed.
  @readonly
  String? _error;

  _AuthBase({required this.twitchApi}) : user = UserStore(twitchApi: twitchApi);

  /// Initialize by retrieving a token if it does not already exist.
  @action
  Future<void> init() async {
    try {
      // Read and set the currently stored user token, if any.
      _token = await _storage.read(key: _userTokenKey);

      // If the token does not exist, get the default token.
      // Otherwise, log in.
      if (_token == null) {
        // Retrieve the currently stored default token if it exists.
        _token = await _storage.read(key: _defaultTokenKey);
        // If the token does not exist or is invalid, get a new token and store it.
        if (_token == null || !await twitchApi.validateToken(token: _token!)) {
          _token = await twitchApi.getDefaultToken();
          await _storage.write(key: _defaultTokenKey, value: _token);
        }
      } else {
        // Validate the existing token.
        _tokenIsValid = await twitchApi.validateToken(token: _token!);

        // If the token is invalid, logout.
        if (!_tokenIsValid) return await logout();

        // Initialize the user store.
        await user.init(headers: headersTwitch);

        if (user.details != null) _isLoggedIn = true;
      }

      _error = null;
    } catch (e) {
      debugPrint(e.toString());
      _error = e.toString();
    }
  }

  /// Initiates the OAuth sign-in process and updates fields accordingly upon successful login.
  @action
  Future<void> login({String? customToken}) async {
    try {
      if (customToken == null) {
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

        // Retrieve the OAuth redirect URI.
        final result = await FlutterWebAuth.authenticate(
          url: loginUrl.toString(),
          callbackUrlScheme: 'auth',
        );

        // Parse the user token from the redirect URI fragment.
        final url = Uri.parse(result.replaceFirst('#', '?'));
        _token = url.queryParameters['access_token'];
      } else {
        // Validate the custom token.
        _tokenIsValid = await twitchApi.validateToken(token: customToken);
        if (!_tokenIsValid) return;

        // Replace the current default token with the new custom token.
        _token = customToken;
      }

      // Store the user token.
      await _storage.write(key: _userTokenKey, value: customToken ?? _token);

      // Initialize the user with the new token.
      await user.init(headers: headersTwitch);

      // Set the login status to logged in.
      if (user.details != null) _isLoggedIn = true;
    } catch (error) {
      debugPrint('Login failed due to $error');
    }
  }

  /// Logs out the current user and updates fields accordingly.
  @action
  Future<void> logout() async {
    try {
      // Delete the existing user token.
      await _storage.delete(key: _userTokenKey);
      _token = null;

      // Clear the user info.
      user.dispose();

      // If the default token already exists, set it.
      _token = await _storage.read(key: _defaultTokenKey);

      // If the default token does not already exist or it's invalid, get the new default token and store it.
      if (_token == null || !await twitchApi.validateToken(token: _token!)) {
        _token = await twitchApi.getDefaultToken();
        await _storage.write(key: _defaultTokenKey, value: _token);
      }

      // Set the login status to logged out.
      _isLoggedIn = false;

      debugPrint('Successfully logged out');
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

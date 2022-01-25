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
      _token = await _storage.read(key: 'USER_TOKEN');

      // If the token does not exist, get the default token.
      // Otherwise, log in.
      if (_token == null) {
        // Retrieve the currently stored default token if it exists.
        _token = await _storage.read(key: 'DEFAULT_TOKEN');
        // If the token does not exist, get a new token and store it.
        if (_token == null) {
          _token = await twitchApi.getDefaultToken();
          await _storage.write(key: 'DEFAULT_TOKEN', value: _token);
        }
      } else {
        // Initialize the user store.
        await user.init(headers: headersTwitch);

        if (user.details != null) _isLoggedIn = true;
      }

      // Validate the token.
      _tokenIsValid = await twitchApi.validateToken(token: _token!);

      // If the token is invalid, logout.
      if (!_tokenIsValid) await logout();

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
        _token = customToken;
      }

      _tokenIsValid = await twitchApi.validateToken(token: _token!);
      if (!_tokenIsValid) return;

      // Store the user token.
      await _storage.write(key: 'USER_TOKEN', value: customToken ?? _token);

      // Initialize the user with the new token.
      await user.init(headers: headersTwitch);

      // Set the login status to logged in.
      _isLoggedIn = true;
    } catch (error) {
      debugPrint('Login failed due to $error');
    }
  }

  /// Logs out the current user and updates fields accordingly.
  @action
  Future<void> logout() async {
    try {
      // Revoke the existing user token and delete it.
      await twitchApi.revokeToken(token: _token!);
      await _storage.delete(key: 'USER_TOKEN');
      _token = null;

      // Clear the user info.
      user.dispose();

      // If the default token already exists, set it.
      _token = await _storage.read(key: 'DEFAULT_TOKEN');

      // If the default token does not already exist, get the new default token and store it.
      // Else, validate the existing token.
      if (_token == null) {
        _token = await twitchApi.getDefaultToken();
        await _storage.write(key: 'DEFAULT_TOKEN', value: _token);
        _tokenIsValid = await twitchApi.validateToken(token: _token!);
      } else {
        // Validate the stored token.
        _tokenIsValid = await twitchApi.validateToken(token: _token!);

        // If the stored token is invalid, get a new default token and store it.
        if (!_tokenIsValid) {
          _token = await twitchApi.getDefaultToken();
          await _storage.write(key: 'DEFAULT_TOKEN', value: _token);
          _tokenIsValid = await twitchApi.validateToken(token: _token!);
        }
      }

      // Set the login status to logged out.
      _isLoggedIn = false;

      debugPrint('Successfully logged out');
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

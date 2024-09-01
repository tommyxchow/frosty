import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/settings/stores/user_store.dart';
import 'package:mobx/mobx.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'auth_store.g.dart';

class AuthStore = AuthBase with _$AuthStore;

abstract class AuthBase with Store {
  /// Secure storage to store tokens.
  static const _storage = FlutterSecureStorage();

  /// The shared_preferences key for the default token.
  static const _defaultTokenKey = 'default_token';

  /// The shared_preferences key for the user token.
  static const _userTokenKey = 'user_token';

  /// The Twitch API service for making requests.
  final TwitchApi twitchApi;

  /// Whether the token is valid or not.
  var _tokenIsValid = false;

  /// The MobX store containing information relevant to the current user.
  final UserStore user;

  /// The user token used to authenticate with the Twitch API.
  @readonly
  String? _token;

  /// Whether the user is logged in or not.
  @readonly
  var _isLoggedIn = false;

  /// Authentication headers for Twitch API requests.
  @computed
  Map<String, String> get headersTwitch =>
      {'Authorization': 'Bearer $_token', 'Client-Id': clientId};

  /// Error flag that will be non-null and contain an error message if login failed.
  @readonly
  String? _error;

  /// Navigation handler for the login webview. Fires on every navigation request (whenever the URL changes).
  FutureOr<NavigationDecision> handleNavigation({
    required NavigationRequest request,
    Widget? routeAfter,
  }) {
    // Check if the URL is the redirect URI.
    if (request.url.startsWith('https://twitch.tv/login')) {
      // Extract the token from the query parameters.
      final uri = Uri.parse(request.url.replaceFirst('#', '?'));
      final token = uri.queryParameters['access_token'];

      // Login with the provided token.
      if (token != null) login(token: token);
    }

    // Check if the the URL has been redirected to "https://www.twitch.tv/?no-reload=true".
    // When redirected to the redirect_uri, there will be another redirect to "https://www.twitch.tv/?no-reload=true".
    // Checking for this will ensure that the user has automatically logged in to Twitch on the WebView itself.
    if (request.url == 'https://www.twitch.tv/?no-reload=true') {
      if (routeAfter != null) {
        navigatorKey.currentState?.pop();
        navigatorKey.currentState
            ?.push(MaterialPageRoute(builder: (context) => routeAfter));
      } else {
        // Pop twice, once to dismiss the WebView and again to dismiss the Login dialog.
        navigatorKey.currentState?.pop();
        navigatorKey.currentState?.pop();
      }
    }

    // Always allow navigation to the next URL.
    return NavigationDecision.navigate;
  }

  WebViewController createAuthWebViewController({Widget? routeAfter}) {
    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    return webViewController
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              handleNavigation(request: request, routeAfter: routeAfter),
          onPageFinished: (_) => webViewController.runJavaScript(
            '''
            {
              function modifyElement(element) {
                element.style.maxHeight = '20vh';
                element.style.overflow = 'auto';
              }

              const observer = new MutationObserver((mutations) => {
                for (let mutation of mutations) {
                  if (mutation.type === 'childList') {
                    const element = document.querySelector('.fAVISI');
                    if (element) {
                      modifyElement(element);
                      observer.disconnect();
                      break;
                    }
                  }
                }
              });

              observer.observe(document.body, {
                childList: true,
                subtree: true
              });
            }
            ''',
          ),
        ),
      )
      ..loadRequest(
        Uri(
          scheme: 'https',
          host: 'id.twitch.tv',
          path: '/oauth2/authorize',
          queryParameters: {
            'client_id': clientId,
            'redirect_uri': 'https://twitch.tv/login',
            'response_type': 'token',
            'scope':
                'chat:read chat:edit user:read:follows user:read:blocked_users user:manage:blocked_users',
            'force_verify': 'true',
          },
        ),
      );
  }

  /// Shows a dialog verifying that the user is sure they want to block/unblock the target user.
  Future<void> showBlockDialog(
    BuildContext context, {
    required String targetUser,
    required String targetUserId,
  }) {
    final isBlocked = user.blockedUsers
        .where((blockedUser) => blockedUser.userId == targetUserId)
        .isNotEmpty;

    final title = isBlocked ? 'Unblock' : 'Block';

    final message =
        'Are you sure you want to ${isBlocked ? 'unblock "$targetUser"?' : 'block "$targetUser"? This will remove them from channel lists, search results, and chat messages.'}';

    void onPressed() {
      if (isBlocked) {
        user.unblock(targetId: targetUserId, headers: headersTwitch);
      } else {
        user.block(
          targetId: targetUserId,
          displayName: targetUser,
          headers: headersTwitch,
        );
      }
      Navigator.pop(context);
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onPressed,
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  AuthBase({required this.twitchApi}) : user = UserStore(twitchApi: twitchApi);

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

  /// Logs in the user with the provided [token] and updates fields accordingly upon successful login.
  @action
  Future<void> login({required String token}) async {
    try {
      // Validate the custom token.
      _tokenIsValid = await twitchApi.validateToken(token: token);
      if (!_tokenIsValid) return;

      // Replace the current default token with the new custom token.
      _token = token;

      // Store the user token.
      await _storage.write(key: _userTokenKey, value: token);

      // Initialize the user with the new token.
      await user.init(headers: headersTwitch);

      // Set the login status to logged in.
      if (user.details != null) _isLoggedIn = true;
    } catch (e) {
      debugPrint('Login failed due to $e');
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

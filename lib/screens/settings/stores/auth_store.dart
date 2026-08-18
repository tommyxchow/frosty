import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/settings/stores/user_store.dart';
import 'package:frosty/services/cookie_extractor.dart';
import 'package:frosty/utils/twitch_oauth_scopes.dart' as twitch_scopes;
import 'package:frosty/widgets/frosty_dialog.dart';
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

  /// The secure storage key for the GQL web cookie token.
  static const _gqlTokenKey = 'gql_token';

  /// Twitch user id that opted into moderator scopes on this device.
  static const _moderatorOptInUserIdKey = 'moderator_scopes_opt_in_user_id';

  /// Last logged-in Twitch user id (kept across logout for re-login scope choice).
  static const _lastUserIdKey = 'last_user_id';

  /// The Twitch API service for making requests.
  final TwitchApi twitchApi;

  /// Timer used to retry authentication when offline or on transient failures.
  Timer? _reconnectTimer;

  /// Retry count for reconnection attempts.
  var _reconnectAttempts = 0;

  /// Maximum number of reconnection attempts before giving up.
  static const _maxReconnectAttempts = 5;

  /// The MobX store containing information relevant to the current user.
  late final UserStore user;

  /// The user token used to authenticate with the Twitch API.
  @readonly
  String? _token;

  /// Web cookie token extracted from the login WebView for GQL ad-free playback.
  @readonly
  String? _gqlToken;

  /// Whether the user is logged in or not.
  @readonly
  var _isLoggedIn = false;

  /// OAuth scopes granted to the current user token.
  @readonly
  var _grantedScopes = ObservableList<String>();

  /// Twitch user id that previously enabled moderator tools on this device.
  String? _moderatorOptInUserId;

  /// Last known Twitch user id, retained after logout for scope selection.
  String? _lastUserId;

  /// Whether the current token includes every moderator scope Frosty needs.
  @computed
  bool get hasModeratorScopes =>
      twitch_scopes.hasModeratorScopes(_grantedScopes);

  /// Authentication headers for Twitch API requests.
  @computed
  Map<String, String> get headersTwitch => {
    'Authorization': 'Bearer $_token',
    'Client-Id': clientId,
  };

  /// Error flag that will be non-null and contain an error message if login failed.
  @readonly
  String? _error;

  /// Navigation handler for the login webview. Fires on every navigation request (whenever the URL changes).
  FutureOr<NavigationDecision> handleNavigation({
    required NavigationRequest request,
    Widget? routeAfter,
    bool upgradeModeratorScopes = false,
  }) {
    // Check if the URL is the redirect URI.
    if (request.url.startsWith('https://twitch.tv/login')) {
      // Extract the token from the query parameters.
      final uri = Uri.parse(request.url.replaceFirst('#', '?'));
      final token = uri.queryParameters['access_token'];

      if (token != null) {
        if (upgradeModeratorScopes) {
          unawaited(completeModeratorUpgrade(token: token));
        } else {
          unawaited(login(token: token));
        }
      }
    }

    // Check if the URL has been redirected to "https://www.twitch.tv/?no-reload=true".
    // When redirected to the redirect_uri, there will be another redirect to "https://www.twitch.tv/?no-reload=true".
    // Checking for this will ensure that the user has automatically logged in to Twitch on the WebView itself.
    if (request.url == 'https://www.twitch.tv/?no-reload=true') {
      _extractGqlToken();

      // Upgrade WebViews pop themselves after an atomic commit so we never
      // dismiss into a half-applied session.
      if (upgradeModeratorScopes) {
        return NavigationDecision.navigate;
      }

      if (routeAfter != null) {
        navigatorKey.currentState?.pop();
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => routeAfter),
        );
      } else {
        // Pop the WebView to return to the previous screen
        navigatorKey.currentState?.pop();
      }
    }

    // Always allow navigation to the next URL.
    return NavigationDecision.navigate;
  }

  WebViewController createAuthWebViewController({
    Widget? routeAfter,
    bool upgradeModeratorScopes = false,
  }) {
    final webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Use platform-specific user agents to allow Google OAuth sign-in.
      // Google blocks OAuth in embedded WebViews (error 403: disallowed_useragent)
      // by detecting WebView markers. These standard browser UAs work around that.
      ..setUserAgent(
        Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1'
            : 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36',
      );

    final scopeQuery = upgradeModeratorScopes || _shouldIncludeModeratorScopes
        ? twitch_scopes.twitchAllUserScopeQuery
        : twitch_scopes.twitchUserScopeQuery;

    return webViewController
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => handleNavigation(
            request: request,
            routeAfter: routeAfter,
            upgradeModeratorScopes: upgradeModeratorScopes,
          ),
          onWebResourceError: (error) {
            debugPrint('Auth WebView error: ${error.description}');
          },
          onPageFinished: (_) async {
            try {
              await webViewController.runJavaScript('''
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
                ''');
            } catch (e) {
              debugPrint('Auth WebView JavaScript error: $e');
            }
          },
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
            'scope': scopeQuery,
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
        user.unblock(targetId: targetUserId);
      } else {
        user.block(targetId: targetUserId, displayName: targetUser);
      }
      Navigator.pop(context);
    }

    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: title,
        message: message,
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: onPressed, child: const Text('Yes')),
        ],
      ),
    );
  }

  AuthBase({required this.twitchApi}) {
    user = UserStore(
      twitchApi: twitchApi,
      hasModeratorScopes: () => hasModeratorScopes,
    );
  }

  bool get _shouldIncludeModeratorScopes {
    final currentId = user.details?.id;
    if (currentId != null && currentId == _moderatorOptInUserId) {
      return true;
    }
    // After logout, still request mod scopes for the same opted-in account.
    if (currentId == null &&
        _lastUserId != null &&
        _lastUserId == _moderatorOptInUserId) {
      return true;
    }
    return false;
  }

  Future<void> _extractGqlToken() async {
    try {
      final token = await CookieExtractor.extractTwitchAuthToken();
      if (token != null) {
        runInAction(() {
          _gqlToken = token;
        });
        await _storage.write(key: _gqlTokenKey, value: token);
      }
    } catch (e) {
      debugPrint('GQL token extraction failed: $e');
    }
  }

  /// Clears the stored web session token after Twitch rejects it, so the
  /// profile card reflects the unlinked state and future stream loads skip
  /// the doomed authenticated request.
  @action
  Future<void> invalidateGqlToken() async {
    _gqlToken = null;
    await _storage.delete(key: _gqlTokenKey);
  }

  void _setGrantedScopes(List<String> scopes) {
    _grantedScopes = ObservableList.of(scopes);
  }

  Future<void> _persistModeratorOptIn(String userId) async {
    if (_moderatorOptInUserId == userId) return;
    _moderatorOptInUserId = userId;
    await _storage.write(key: _moderatorOptInUserIdKey, value: userId);
  }

  Future<void> _persistLastUserId(String? userId) async {
    if (_lastUserId == userId) return;
    _lastUserId = userId;
    if (userId == null) {
      await _storage.delete(key: _lastUserIdKey);
    } else {
      await _storage.write(key: _lastUserIdKey, value: userId);
    }
  }

  /// Initialize by retrieving a token if it does not already exist.
  @action
  Future<void> init() async {
    try {
      final stored = await Future.wait([
        _storage.read(key: _moderatorOptInUserIdKey),
        _storage.read(key: _lastUserIdKey),
        _storage.read(key: _userTokenKey),
        _storage.read(key: _gqlTokenKey),
      ]);
      _moderatorOptInUserId = stored[0];
      _lastUserId = stored[1];
      _token = stored[2];
      _gqlToken = stored[3];

      // If the token does not exist, get the default token.
      // Otherwise, log in.
      if (_token == null) {
        // Retrieve the currently stored default token if it exists.
        _token = await _storage.read(key: _defaultTokenKey);
        // If the token does not exist or is invalid, get a new token and store it.
        if (_token == null ||
            await twitchApi.validateToken(token: _token!) == null) {
          _token = await twitchApi.getDefaultToken();
          await _storage.write(key: _defaultTokenKey, value: _token);
        }
        _setGrantedScopes(const []);
      } else {
        // Validate the existing token. If it fails, start reconnect loop.
        final TwitchTokenInfo info;
        try {
          final validated = await twitchApi.validateToken(token: _token!);
          if (validated == null) return await logout();
          info = validated;
        } on ApiException catch (e) {
          debugPrint('Token validation failed: $e');
          _isLoggedIn = false;
          _setGrantedScopes(const []);
          _startReconnectLoop();
          return;
        }

        _setGrantedScopes(info.scopes);

        // Initialize the user store.
        await user.init();

        if (user.details != null) {
          _isLoggedIn = true;
          await _persistLastUserId(user.details!.id);
          _stopReconnectLoop();

          // Recover a missed web session link — the WebView cookie store may
          // still hold a valid auth-token from a previous login.
          if (_gqlToken == null) _extractGqlToken();
        }
      }

      FirebaseCrashlytics.instance.setCustomKey('is_logged_in', _isLoggedIn);
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
      final info = await twitchApi.validateToken(token: token);
      if (info == null) return;
      _setGrantedScopes(info.scopes);

      // Replace the current default token with the new custom token.
      _token = token;

      // Store the user token.
      await _storage.write(key: _userTokenKey, value: token);

      // Initialize the user with the new token.
      await user.init();

      // Set the login status to logged in.
      if (user.details != null) {
        _isLoggedIn = true;
        await _persistLastUserId(user.details!.id);
        // A fresh login that already includes mod scopes (re-auth after opt-in)
        // should keep the opt-in flag for this account.
        if (hasModeratorScopes) {
          await _persistModeratorOptIn(user.details!.id);
        }
        FirebaseCrashlytics.instance.setCustomKey('is_logged_in', true);
        FirebaseCrashlytics.instance.setUserIdentifier(user.details!.id);
        _stopReconnectLoop();
      }
    } catch (e) {
      debugPrint('Login failed due to $e');
    }
  }

  /// Atomically upgrades the current session with moderator OAuth scopes.
  ///
  /// Keeps the existing token until validation proves the new token is for the
  /// same user and includes every moderator scope. On any failure, the old
  /// session is left untouched.
  @action
  Future<bool> completeModeratorUpgrade({required String token}) async {
    final currentUserId = user.details?.id;
    if (currentUserId == null || !_isLoggedIn) {
      _showModeratorUpgradeFailed(
        'Log in first, then enable moderator tools from a channel you moderate.',
      );
      return false;
    }

    try {
      final info = await twitchApi.validateToken(token: token);
      if (info == null) {
        _showModeratorUpgradeFailed(
          'Could not validate the new Twitch permissions. Your current session was kept.',
        );
        return false;
      }

      if (info.userId != currentUserId) {
        _showModeratorUpgradeFailed(
          'Log in with the same Twitch account to enable moderator tools. Your current session was kept.',
        );
        return false;
      }

      if (!twitch_scopes.hasModeratorScopes(info.scopes)) {
        _showModeratorUpgradeFailed(
          'Moderator permissions were not granted. Your current session was kept.',
        );
        return false;
      }

      // Commit only after all gates pass.
      _token = token;
      _setGrantedScopes(info.scopes);
      await Future.wait([
        _storage.write(key: _userTokenKey, value: token),
        _persistModeratorOptIn(currentUserId),
      ]);
      await user.refreshModeratedChannels();

      navigatorKey.currentState?.pop();
      return true;
    } catch (e) {
      debugPrint('Moderator upgrade failed due to $e');
      _showModeratorUpgradeFailed(
        'Could not enable moderator tools. Your current session was kept.',
      );
      return false;
    }
  }

  void _showModeratorUpgradeFailed(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    showDialog(
      context: context,
      builder: (dialogContext) => FrostyDialog(
        title: 'Moderator tools not enabled',
        message: message,
        actions: [
          TextButton(
            onPressed: Navigator.of(dialogContext).pop,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Logs out the current user and updates fields accordingly.
  @action
  Future<void> logout() async {
    try {
      _stopReconnectLoop();
      final previousUserId = user.details?.id ?? _lastUserId;
      await _persistLastUserId(previousUserId);

      // Delete the existing user token and GQL token.
      await _storage.delete(key: _userTokenKey);
      await _storage.delete(key: _gqlTokenKey);
      _token = null;
      _gqlToken = null;
      _setGrantedScopes(const []);

      // Clear the user info.
      user.dispose();

      // If the default token already exists, set it.
      _token = await _storage.read(key: _defaultTokenKey);

      // If the default token does not already exist or it's invalid, get the new default token and store it.
      if (_token == null ||
          await twitchApi.validateToken(token: _token!) == null) {
        _token = await twitchApi.getDefaultToken();
        await _storage.write(key: _defaultTokenKey, value: _token);
      }

      // Set the login status to logged out.
      _isLoggedIn = false;
      FirebaseCrashlytics.instance.setCustomKey('is_logged_in', false);
      FirebaseCrashlytics.instance.setUserIdentifier('');

      debugPrint('Successfully logged out');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _startReconnectLoop() {
    if (_reconnectTimer != null) return;
    _reconnectAttempts = 0;
    _reconnectTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        _reconnectAttempts++;
        if (_reconnectAttempts > _maxReconnectAttempts) {
          FirebaseCrashlytics.instance.log(
            'Auth reconnection exhausted after $_maxReconnectAttempts attempts',
          );
          await logout();
          return;
        }

        final stored = await _storage.read(key: _userTokenKey);
        if (stored == null) {
          _stopReconnectLoop();
          return;
        }

        final info = await twitchApi.validateToken(token: stored);
        if (info == null) {
          await logout();
          return;
        }

        // Token valid again — restore session.
        _token = stored;
        _setGrantedScopes(info.scopes);
        await user.init();
        if (user.details != null) {
          _isLoggedIn = true;
          await _persistLastUserId(user.details!.id);
          _error = null;
          _stopReconnectLoop();
        }
      } on ApiException catch (_) {
        // Continue trying
      } catch (e) {
        debugPrint('Reconnect loop error: $e');
      }
    });
  }

  void _stopReconnectLoop() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }
}

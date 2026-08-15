import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/onboarding/login_webview.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/utils/twitch_oauth_scopes.dart';
import 'package:frosty/widgets/frosty_dialog.dart';
import 'package:provider/provider.dart';

/// Dio interceptor that catches 401 Unauthorized errors and shows a login dialog
class UnauthorizedInterceptor extends Interceptor {
  final AuthStore _authStore;

  UnauthorizedInterceptor(this._authStore);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if this is a 401 Unauthorized error on a Twitch Helix/OAuth request
    if (err.response?.statusCode == 401 &&
        _isTwitchHelixOrOAuth(err.requestOptions.uri)) {
      // For token validation requests, let the error propagate so validateToken can handle it
      if (err.requestOptions.uri.path.endsWith('/validate')) {
        handler.next(err);
        return;
      }

      final path = err.requestOptions.uri.path;

      // Background moderated-channels fetches must never nag — especially for
      // core-only tokens after an app upgrade.
      if (isTwitchModeratedChannelsPath(path)) {
        handler.reject(err);
        return;
      }

      // Moderator actions without scopes → opt-in Enable flow, not a generic
      // "missing permissions" re-login for core scopes.
      if (isTwitchModeratorActionPath(path) &&
          !_authStore.hasModeratorScopes) {
        _showAuthDialog(
          title: 'Enable moderator tools',
          message: enableModeratorToolsDialogMessage(),
          primaryLabel: 'Enable',
          onPrimary: () => openEnableModeratorTools(_authStore),
        );
        handler.reject(err);
        return;
      }

      // Core-only messaging: if core scopes are present, prefer "Session expired"
      // over "Missing permissions" (401 ≠ always missing scope).
      final isLoggedIn = _authStore.isLoggedIn;
      final missingCore = missingTwitchScopes(
        granted: _authStore.grantedScopes,
      );
      _showAuthDialog(
        title: isLoggedIn && missingCore.isNotEmpty
            ? 'Missing permissions'
            : 'Session expired',
        message: unauthorizedDialogMessage(
          isLoggedIn: isLoggedIn,
          grantedScopes: _authStore.grantedScopes,
        ),
        primaryLabel: 'Log in',
        onPrimary: () {
          final context = navigatorKey.currentContext;
          if (context == null) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Provider<AuthStore>.value(
                value: _authStore,
                child: const LoginWebView(),
              ),
            ),
          );
        },
      );
      handler.reject(err);
      return;
    }

    // For non-401 errors, continue with normal error handling
    handler.next(err);
  }

  void _showAuthDialog({
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback onPrimary,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return FrostyDialog(
          title: title,
          message: message,
          actions: [
            TextButton(
              onPressed: () {
                _isDialogShowing = false;
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _isDialogShowing = false;
                Navigator.of(dialogContext).pop();
                onPrimary();
              },
              child: Text(primaryLabel),
            ),
          ],
        );
      },
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  static bool _isDialogShowing = false;

  bool _isTwitchHelixOrOAuth(Uri uri) {
    final url = uri.toString();
    return url.startsWith('https://api.twitch.tv/helix') ||
        url.startsWith('https://id.twitch.tv/oauth2');
  }
}

/// Helix path for listing channels the user moderates.
bool isTwitchModeratedChannelsPath(String path) =>
    path.contains('/moderation/channels');

/// Helix paths for delete / ban / timeout / unban.
bool isTwitchModeratorActionPath(String path) =>
    path.contains('/moderation/chat') || path.contains('/moderation/bans');

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/onboarding/login_webview.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/frosty_dialog.dart';
import 'package:provider/provider.dart';

/// Dio interceptor that catches 401 Unauthorized errors and shows a login dialog
class UnauthorizedInterceptor extends Interceptor {
  final AuthStore _authStore;

  UnauthorizedInterceptor(this._authStore);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if this is a 401 Unauthorized error
    if (err.response?.statusCode == 401) {
      // For token validation requests, let the error propagate so validateToken can handle it
      if (err.requestOptions.uri.path.endsWith('/validate')) {
        handler.next(err);
        return;
      }

      // For other requests, show login dialog and don't propagate
      _showLoginDialog();
      return;
    }

    // For non-401 errors, continue with normal error handling
    handler.next(err);
  }

  void _showLoginDialog() {
    // Use the global navigator key to show dialog without needing BuildContext
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Use a flag to prevent multiple dialogs
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    // Determine if user is logged in but missing scopes vs completely logged out
    final isLoggedIn = _authStore.isLoggedIn;
    final title = isLoggedIn ? 'Missing permissions' : 'Session expired';
    final message = isLoggedIn
        ? 'Your session is missing permissions. Please log in again to continue.'
        : 'Your session has expired. Please log in again to continue.';

    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an action
      builder: (BuildContext dialogContext) {
        return FrostyDialog(
          title: title,
          message: message,
          actions: [
            TextButton(
              onPressed: () {
                _isDialogShowing = false;
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _isDialogShowing = false;
                Navigator.of(dialogContext).pop(); // Close dialog
                // Navigate to login WebView
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Provider<AuthStore>.value(
                      value: _authStore,
                      child: const LoginWebView(),
                    ),
                  ),
                );
              },
              child: Text('Log in'),
            ),
          ],
        );
      },
    ).then((_) {
      // Reset flag when dialog is dismissed
      _isDialogShowing = false;
    });
  }

  static bool _isDialogShowing = false;
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/onboarding/login_webview.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:provider/provider.dart';

/// Dio interceptor that catches 401 Unauthorized errors and shows a login dialog
class UnauthorizedInterceptor extends Interceptor {
  final AuthStore _authStore;

  UnauthorizedInterceptor(this._authStore);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if this is a 401 Unauthorized error
    if (err.response?.statusCode == 401) {
      // Show login dialog
      _showLoginDialog();
      // Don't call handler.next() to prevent the error from propagating further
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
    final title = isLoggedIn ? 'Missing Permissions' : 'Session Expired';
    final content = isLoggedIn
        ? 'Your account is missing required permissions. Please re-authorize to continue.'
        : 'Your login session has expired. Please log in again to continue.';
    final buttonText = isLoggedIn ? 'Re-authorize' : 'Log In';

    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an action
      builder: (BuildContext dialogContext) {
        return FrostyDialog(
          title: title,
          message: content,
          actions: [
            ElevatedButton(
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
              child: Text(buttonText),
            ),
            TextButton(
              onPressed: () {
                _isDialogShowing = false;
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text('Cancel'),
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

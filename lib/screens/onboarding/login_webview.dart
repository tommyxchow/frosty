import 'package:flutter/material.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Reusable WebView widget for Twitch OAuth login flow
class LoginWebView extends StatelessWidget {
  /// Optional widget to navigate to after successful login
  final Widget? routeAfter;

  const LoginWebView({
    super.key,
    this.routeAfter,
  });

  @override
  Widget build(BuildContext context) {
    final authStore = context.read<AuthStore>();

    return Scaffold(
      appBar: FrostyAppBar(
        title: const Text('Connect with Twitch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_rounded),
            onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Workaround for the Twitch cookie banner'),
                  content: const Text(
                    'If the Twitch cookie banner is still blocking the login, try clicking one of the links in the cookie policy description and navigating until you reach the Twitch home page. From there, you can try logging in on the top right profile icon. Once logged in, go back to the first step of the onboarding and then try again.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: WebViewWidget(
        controller: authStore.createAuthWebViewController(
          routeAfter: routeAfter,
        ),
      ),
    );
  }
}

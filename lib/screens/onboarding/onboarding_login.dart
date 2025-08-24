import 'package:flutter/material.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';
import 'package:frosty/screens/onboarding/onboarding_setup.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnboardingLogin extends StatelessWidget {
  const OnboardingLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final authStore = context.read<AuthStore>();

    return OnboardingScaffold(
      header: 'Log in',
      subtitle:
          'Frosty needs your permission in order to enable the ability to chat, view followed streams, and more.',
      disclaimer:
          'Frosty only asks for the necessary permissions through the official Twitch API. You\'ll be able to review them before authorizing.',
      buttonText: 'Connect with Twitch',
      buttonIcon: const Icon(SimpleIcons.twitch),
      skipRoute: const OnboardingSetup(),
      route: Scaffold(
        appBar: FrostyAppBar(
          title: const Text('Connect with Twitch'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_rounded),
              onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title:
                        const Text('Workaround for the Twitch cookie banner'),
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
            routeAfter: const OnboardingSetup(),
          ),
        ),
      ),
    );
  }
}

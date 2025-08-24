import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';
import 'package:frosty/screens/onboarding/onboarding_setup.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/blurred_container.dart';
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
          ),
          leading: IconButton(
            tooltip: 'Back',
            icon: Icon(Icons.adaptive.arrow_back_rounded),
            onPressed: Navigator.of(context).pop,
          ),
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
        body: Stack(
          children: [
            // WebView content
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight,
                ),
                child: WebViewWidget(
                  controller: authStore.createAuthWebViewController(
                    routeAfter: const OnboardingSetup(),
                  ),
                ),
              ),
            ),
            // Blurred app bar overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BlurredContainer(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: MediaQuery.of(context).padding.left,
                  right: MediaQuery.of(context).padding.right,
                ),
                child: const SizedBox(height: kToolbarHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

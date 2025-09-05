import 'package:flutter/material.dart';
import 'package:frosty/screens/onboarding/login_webview.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';
import 'package:frosty/screens/onboarding/onboarding_setup.dart';
import 'package:simple_icons/simple_icons.dart';

class OnboardingLogin extends StatelessWidget {
  const OnboardingLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      header: 'Log in',
      subtitle:
          'Frosty needs your permission in order to enable the ability to chat, view followed streams, and more.',
      disclaimer:
          'Frosty only asks for the necessary permissions through the official Twitch API. You\'ll be able to review them before authorizing.',
      buttonText: 'Connect with Twitch',
      buttonIcon: const Icon(SimpleIcons.twitch),
      skipRoute: const OnboardingSetup(),
      route: LoginWebView(
        routeAfter: const OnboardingSetup(),
      ),
    );
  }
}

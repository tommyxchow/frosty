import 'package:flutter/material.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';
import 'package:frosty/screens/onboarding/onboarding_setup.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnboardingLogin extends StatelessWidget {
  const OnboardingLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authStore = context.read<AuthStore>();

    return OnboardingScaffold(
      header: 'Log in',
      subtitle: 'Frosty needs your permission in order to enable the ability to chat, view followed streams, and more.',
      disclaimer:
          'Frosty only asks for the necessary permissions through the official Twitch API. You\'ll be able to review them before authorizing.',
      buttonText: 'Connect with Twitch',
      buttonIcon: const Icon(SimpleIcons.twitch),
      skipRoute: const OnboardingSetup(),
      route: Scaffold(
        appBar: const FrostyAppBar(
          title: Text('Connect with Twitch'),
        ),
        body: WebViewWidget(
          controller: authStore.webViewController
            ..setNavigationDelegate(authStore.createNavigationDelegate(routeWhenLogin: const OnboardingSetup()))
            ..loadRequest(authStore.loginUri),
        ),
      ),
    );
  }
}

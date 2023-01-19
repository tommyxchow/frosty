import 'package:flutter/material.dart';
import 'package:frosty/screens/onboarding/onboarding_login.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';

class OnboardingIntro extends StatelessWidget {
  const OnboardingIntro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OnboardingScaffold(
      header: 'Frosty',
      subtitle:
          'A mobile Twitch client for iOS and Android with 7TV, BetterTTV (BTTV), and FrankerFaceZ (FFZ) support.',
      showLogo: true,
      route: OnboardingLogin(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frosty/screens/home/home.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';

class OnboardingWelcome extends StatelessWidget {
  const OnboardingWelcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const text = [
      'Frosty is completely free and open-source. If you\'d like to explore the source code, report an issue, or make a feature request, check out the GitHub repo (link at the top-right of settings).',
      'You can also find links to the full changelog and FAQ in Settings -> Other.',
      'Don\'t forget to leave a rating and/or review on the app store!',
    ];

    return OnboardingScaffold(
      header: 'Welcome!',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Opacity(
          opacity: 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: text
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        e,
                        textAlign: TextAlign.center,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
      buttonText: 'Lets go!',
      isLast: true,
      route: const Home(),
    );
  }
}

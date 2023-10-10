import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosty/screens/home/home.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';

class OnboardingWelcome extends StatelessWidget {
  const OnboardingWelcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const text = [
      'Check out the GitHub repo at the top-right of the settings page to explore Frosty\'s source code, report bugs, make feature requests, and more.',
      'Links to the full changelog and FAQ are in the settings page under "Other".',
      'Don\'t forget to leave a rating and/or review on the app store!',
    ];

    return OnboardingScaffold(
      header: 'Welcome!',
      subtitle: 'Just a few more things...',
      content: Opacity(
        opacity: 0.8,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: text
              .mapIndexed(
                (index, sentence) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ListTile(
                    leading: Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    title: Text(sentence),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      buttonText: 'Let\'s go!',
      isLast: true,
      route: const Home(),
    );
  }
}

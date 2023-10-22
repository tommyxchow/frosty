import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';
import 'package:frosty/screens/onboarding/onboarding_welcome.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:provider/provider.dart';

class OnboardingSetup extends StatelessWidget {
  const OnboardingSetup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsStore = context.read<SettingsStore>();

    return OnboardingScaffold(
      header: 'Setup',
      subtitle:
          'Let\'s tweak some settings before you get started. You can always change these and more later.',
      content: Observer(
        builder: (context) {
          return ListView(
            children: [
              SettingsListSelect(
                title: 'Theme',
                selectedOption: themeNames[settingsStore.themeType.index],
                options: themeNames,
                onChanged: (newTheme) => settingsStore.themeType =
                    ThemeType.values[themeNames.indexOf(newTheme)],
              ),
              SettingsListSwitch(
                title: 'Share crash logs and analytics',
                subtitle: const Text(
                  'Help improve Frosty by sending anonymous crash logs and analytics through Firebase.',
                ),
                value: settingsStore.shareCrashLogsAndAnalytics,
                onChanged: (newValue) {
                  settingsStore.shareCrashLogsAndAnalytics = newValue;

                  FirebaseCrashlytics.instance
                      .setCrashlyticsCollectionEnabled(newValue);
                  FirebaseAnalytics.instance
                      .setAnalyticsCollectionEnabled(newValue);
                  FirebasePerformance.instance
                      .setPerformanceCollectionEnabled(newValue);
                },
              ),
            ],
          );
        },
      ),
      route: const OnboardingWelcome(),
    );
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';
import 'package:frosty/screens/onboarding/onboarding_welcome.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingSetup extends StatelessWidget {
  const OnboardingSetup({super.key});

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
              ListTile(
                title: const Text('Accent color'),
                trailing: IconButton(
                  icon: DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Color(settingsStore.accentColor),
                      radius: 16,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => FrostyDialog(
                        title: 'Accent color',
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: Color(settingsStore.accentColor),
                            onColorChanged: (newColor) =>
                                // TODO: Update when new method arrives in stable:
                                // https://github.com/flutter/flutter/issues/160184#issuecomment-2560184639
                                // ignore: deprecated_member_use
                                settingsStore.accentColor = newColor.value,
                            enableAlpha: false,
                            pickerAreaBorderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            labelTypes: const [],
                          ),
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SettingsListSwitch(
                title: 'Show historical recent messages',
                subtitle: Text.rich(
                  TextSpan(
                    text:
                        'Loads historical recent messages in chat through a third-party API service at ',
                    children: [
                      TextSpan(
                        text: 'https://recent-messages.robotty.de/',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                                Uri.parse(
                                  'https://recent-messages.robotty.de/',
                                ),
                                mode: settingsStore.launchUrlExternal
                                    ? LaunchMode.externalApplication
                                    : LaunchMode.inAppBrowserView,
                              ),
                      ),
                    ],
                  ),
                ),
                value: settingsStore.showRecentMessages,
                onChanged: (newValue) =>
                    settingsStore.showRecentMessages = newValue,
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

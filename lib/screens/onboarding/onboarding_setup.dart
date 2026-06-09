import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import removed: flutter_colorpicker
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/onboarding/onboarding_scaffold.dart';
import 'package:frosty/screens/onboarding/onboarding_welcome.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/widgets/accent_color_setting.dart';
import 'package:frosty/widgets/theme_selection_setting.dart';
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
              ThemeSelectionSetting(settingsStore: settingsStore),
              AccentColorSetting(settingsStore: settingsStore),
              SettingsListSwitch(
                title: 'Show historical recent messages',
                subtitle: Text.rich(
                  TextSpan(
                    text:
                        'Loads historical recent messages in chat through a third-party API service at ',
                    children: [
                      TextSpan(
                        text: 'https://recent-messages.robotty.de/',
                        style: TextStyle(
                          color: context.colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: context.colorScheme.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                            Uri.parse('https://recent-messages.robotty.de/'),
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
            ],
          );
        },
      ),
      route: const OnboardingWelcome(),
    );
  }
}

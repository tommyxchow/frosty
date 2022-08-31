import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frosty/screens/settings/account_settings.dart';
import 'package:frosty/screens/settings/chat_settings.dart';
import 'package:frosty/screens/settings/general_settings.dart';
import 'package:frosty/screens/settings/other_settings.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/video_settings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  final SettingsStore settingsStore;

  const Settings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (Platform.isAndroid)
            IconButton(
              tooltip: 'Support the app',
              onPressed: () => launchUrl(Uri.parse('https://www.buymeacoffee.com/tommychow'),
                  mode: settingsStore.launchUrlExternal ? LaunchMode.externalApplication : LaunchMode.inAppWebView),
              icon: const FaIcon(FontAwesomeIcons.circleDollarToSlot),
            ),
          IconButton(
            tooltip: 'View source on GitHub',
            onPressed: () => launchUrl(Uri.parse('https://github.com/tommyxchow/frosty'),
                mode: settingsStore.launchUrlExternal ? LaunchMode.externalApplication : LaunchMode.inAppWebView),
            icon: const FaIcon(FontAwesomeIcons.github),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            const SizedBox(height: 10.0),
            AccountSettings(
              settingsStore: settingsStore,
              authStore: context.read<AuthStore>(),
            ),
            GeneralSettings(settingsStore: settingsStore),
            VideoSettings(settingsStore: settingsStore),
            ChatSettings(settingsStore: settingsStore),
            OtherSettings(settingsStore: settingsStore),
          ],
        ),
      ),
    );
  }
}

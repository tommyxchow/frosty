import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frosty/screens/settings/account/widgets/profile_card.dart';
import 'package:frosty/screens/settings/chat_settings.dart';
import 'package:frosty/screens/settings/general_settings.dart';
import 'package:frosty/screens/settings/other_settings.dart';
import 'package:frosty/screens/settings/settings_tile_route.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/video_settings.dart';
import 'package:frosty/widgets/section_header.dart';
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
            const SectionHeader('Account'),
            ProfileCard(authStore: context.read<AuthStore>()),
            const SectionHeader('Customize'),
            SettingsTileRoute(
              leading: const Icon(Icons.settings),
              title: 'General',
              child: GeneralSettings(settingsStore: settingsStore),
            ),
            SettingsTileRoute(
              leading: const Icon(Icons.live_tv),
              title: 'Video',
              child: VideoSettings(settingsStore: settingsStore),
            ),
            SettingsTileRoute(
              leading: const Icon(Icons.chat),
              title: 'Chat',
              child: ChatSettings(settingsStore: settingsStore),
            ),
            const SectionHeader('Other'),
            OtherSettings(settingsStore: settingsStore)
          ],
        ),
      ),
    );
  }
}

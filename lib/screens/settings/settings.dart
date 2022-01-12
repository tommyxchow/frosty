import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/settings/sections/account_settings.dart';
import 'package:frosty/screens/settings/sections/chat_settings.dart';
import 'package:frosty/screens/settings/sections/general_settings.dart';
import 'package:frosty/screens/settings/sections/other_settings.dart';
import 'package:frosty/screens/settings/sections/video_settings.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
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
          IconButton(
            tooltip: 'View source on GitHub',
            onPressed: () => launch('https://github.com/tommyxchow/frosty'),
            icon: const FaIcon(FontAwesomeIcons.github),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          children: [
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

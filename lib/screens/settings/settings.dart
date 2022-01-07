import 'package:flutter/material.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/settings/account/account_settings.dart';
import 'package:frosty/screens/settings/chat_settings.dart';
import 'package:frosty/screens/settings/general_settings.dart';
import 'package:frosty/screens/settings/other_settings.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/video_settings.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  final SettingsStore settingsStore;

  const Settings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
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

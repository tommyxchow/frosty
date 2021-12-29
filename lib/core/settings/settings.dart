import 'package:flutter/material.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/account_settings.dart';
import 'package:frosty/core/settings/chat_settings.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/core/settings/video_settings.dart';
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
      body: ListView(
        children: [
          AccountSettings(settingsStore: settingsStore, authStore: context.read<AuthStore>()),
          VideoSettings(settingsStore: settingsStore),
          ChatSettings(settingsStore: settingsStore),
        ],
      ),
    );
  }
}

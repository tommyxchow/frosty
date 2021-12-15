import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/profile_card.dart';
import 'package:frosty/core/settings/settings_store.dart';
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
      body: Observer(
        builder: (_) {
          return ListView(
            children: [
              ProfileCard(authStore: context.read<AuthStore>()),
              ListTile(
                title: Row(
                  children: [
                    const Text('Chat Message Limit'),
                    const Spacer(),
                    Text(
                      settingsStore.messageLimit == 1000 ? 'Unlimited' : '${settingsStore.messageLimit.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Slider.adaptive(
                  value: settingsStore.messageLimit,
                  onChanged: (newValue) => settingsStore.messageLimit = newValue,
                  min: 200,
                  max: 1000,
                  divisions: 4,
                ),
              ),
              SwitchListTile.adaptive(
                title: const Text('Enable Video'),
                value: settingsStore.videoEnabled,
                onChanged: (newValue) => settingsStore.videoEnabled = newValue,
              ),
              SwitchListTile.adaptive(
                title: const Text('Hide Banned Messages'),
                value: settingsStore.hideBannedMessages,
                onChanged: (newValue) => settingsStore.hideBannedMessages = newValue,
              ),
              SwitchListTile.adaptive(
                title: const Text('Enable Zero-Width Emotes'),
                value: settingsStore.zeroWidthEnabled,
                onChanged: (newValue) => settingsStore.zeroWidthEnabled = newValue,
              ),
            ],
          );
        },
      ),
    );
  }
}

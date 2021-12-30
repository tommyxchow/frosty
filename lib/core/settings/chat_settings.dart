import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';

class ChatSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const ChatSettings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('CHAT'),
            SwitchListTile.adaptive(
              title: const Text('Hide banned messages'),
              value: settingsStore.hideBannedMessages,
              onChanged: (newValue) => settingsStore.hideBannedMessages = newValue,
            ),
            SwitchListTile.adaptive(
              title: const Text('Zero-width emotes'),
              value: settingsStore.zeroWidthEnabled,
              onChanged: (newValue) => settingsStore.zeroWidthEnabled = newValue,
            ),
            SwitchListTile.adaptive(
              title: const Text('Timestamps'),
              value: settingsStore.timeStampsEnabled,
              onChanged: (newValue) => settingsStore.timeStampsEnabled = newValue,
            ),
            SwitchListTile.adaptive(
              title: const Text('12-hour timestamps'),
              value: settingsStore.twelveHourTimeStamp,
              onChanged: settingsStore.timeStampsEnabled ? (newValue) => settingsStore.twelveHourTimeStamp = newValue : null,
            ),
          ],
        );
      },
    );
  }
}

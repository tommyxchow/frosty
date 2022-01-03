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
            const SectionHeader('Chat'),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Hide banned and deleted messages'),
              subtitle: const Text('Replaces deleted, timed-out, and banned user messages with "<message deleted>".'),
              value: settingsStore.hideBannedMessages,
              onChanged: (newValue) => settingsStore.hideBannedMessages = newValue,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Zero-width emotes'),
              subtitle: const Text('Enable the visibility of "stacked" emotes from BetterTTV and 7TV.'),
              value: settingsStore.zeroWidthEnabled,
              onChanged: (newValue) => settingsStore.zeroWidthEnabled = newValue,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Show timestamps'),
              subtitle: const Text('Display 24-hour timestamps for when a chat message was sent.'),
              value: settingsStore.timeStampsEnabled,
              onChanged: (newValue) => settingsStore.timeStampsEnabled = newValue,
            ),
            SwitchListTile.adaptive(
              title: const Text('Use 12-hour timestamps'),
              value: settingsStore.twelveHourTimeStamp,
              onChanged: settingsStore.timeStampsEnabled ? (newValue) => settingsStore.twelveHourTimeStamp = newValue : null,
            ),
          ],
        );
      },
    );
  }
}

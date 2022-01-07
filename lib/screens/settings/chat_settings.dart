import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
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
              title: const Text('Show deleted messages'),
              value: settingsStore.showDeletedMessages,
              onChanged: (newValue) => settingsStore.showDeletedMessages = newValue,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Show zero-width emotes'),
              subtitle: const Text('Makes "stacked" emotes from BetterTTV and 7TV visible in chat messages.'),
              value: settingsStore.showZeroWidth,
              onChanged: (newValue) => settingsStore.showZeroWidth = newValue,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Show message timestamps'),
              subtitle: const Text('Displays timestamps for when a chat message was sent.'),
              value: settingsStore.showTimestamps,
              onChanged: (newValue) => settingsStore.showTimestamps = newValue,
            ),
            SwitchListTile.adaptive(
              title: const Text('Use 12-hour timestamps'),
              value: settingsStore.useTwelveHourTimestamps,
              onChanged: settingsStore.showTimestamps ? (newValue) => settingsStore.useTwelveHourTimestamps = newValue : null,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Use readable colors for chat names'),
              subtitle: const Text('Makes dark names in chat readable by boosting their lightness value.'),
              value: settingsStore.useReadableColors,
              onChanged: (newValue) => settingsStore.useReadableColors = newValue,
            ),
            ListTile(
              isThreeLine: true,
              title: Text('Font scale: ${settingsStore.fontScale.toStringAsFixed(1)}x'),
              subtitle: Slider.adaptive(
                value: settingsStore.fontScale,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (newValue) => settingsStore.fontScale = newValue,
              ),
            ),
            ListTile(
              title: Text('Message spacing: ${settingsStore.messageSpacing.toStringAsFixed(0)}'),
              subtitle: Slider.adaptive(
                value: settingsStore.messageSpacing,
                min: 0.0,
                max: 30.0,
                divisions: 30,
                onChanged: (newValue) => settingsStore.messageSpacing = newValue,
              ),
            ),
            ListTile(
              isThreeLine: true,
              title: const Text('Preview'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello! This is a preview for the font scale.',
                    textScaleFactor: settingsStore.fontScale,
                  ),
                  SizedBox(height: settingsStore.messageSpacing),
                  Text(
                    'This is a another message to see spacing!',
                    textScaleFactor: settingsStore.fontScale,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

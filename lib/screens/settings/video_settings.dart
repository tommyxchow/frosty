import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';

class VideoSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const VideoSettings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('Video'),
            SwitchListTile.adaptive(
              title: const Text('Show video'),
              value: settingsStore.showVideo,
              onChanged: (newValue) => settingsStore.showVideo = newValue,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Use custom video overlay'),
              subtitle: const Text('Replaces the default web video overlay with a simple and mobile-friendly version.'),
              value: settingsStore.showOverlay,
              onChanged: settingsStore.showVideo ? (newValue) => settingsStore.showOverlay = newValue : null,
            ),
          ],
        );
      },
    );
  }
}

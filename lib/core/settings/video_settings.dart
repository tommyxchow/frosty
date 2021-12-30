import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/settings/settings_store.dart';
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
            const SectionHeader('VIDEO'),
            SwitchListTile.adaptive(
              title: const Text('Video'),
              value: settingsStore.videoEnabled,
              onChanged: (newValue) => settingsStore.videoEnabled = newValue,
            ),
            SwitchListTile.adaptive(
              title: const Text('Video overlay'),
              value: settingsStore.overlayEnabled,
              onChanged: settingsStore.videoEnabled ? (newValue) => settingsStore.overlayEnabled = newValue : null,
            ),
          ],
        );
      },
    );
  }
}

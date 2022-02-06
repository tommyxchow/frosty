import 'dart:io';

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
            const SectionHeader(
              'Video',
              padding: EdgeInsets.all(10.0),
            ),
            SwitchListTile.adaptive(
              title: const Text('Show video'),
              value: settingsStore.showVideo,
              onChanged: (newValue) => settingsStore.showVideo = newValue,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Use custom video overlay'),
              subtitle: const Text('Replaces the default video overlay with a mobile-friendly version.'),
              value: settingsStore.showOverlay,
              onChanged: settingsStore.showVideo ? (newValue) => settingsStore.showOverlay = newValue : null,
            ),
            if (Platform.isIOS)
              SwitchListTile.adaptive(
                isThreeLine: true,
                title: const Text('Picture-in-picture button (experimental)'),
                subtitle: const Text('Adds a button to enter PiP mode on the bottom right of the overlay. May cause freezes/crashes.'),
                value: settingsStore.pictureInPicture,
                onChanged: settingsStore.showVideo && settingsStore.showOverlay ? (newValue) => settingsStore.pictureInPicture = newValue : null,
              ),
            SwitchListTile.adaptive(
              title: const Text('Long-press player to toggle overlay'),
              value: settingsStore.toggleableOverlay,
              onChanged: settingsStore.showVideo ? (newValue) => settingsStore.toggleableOverlay = newValue : null,
            ),
          ],
        );
      },
    );
  }
}

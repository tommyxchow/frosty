import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';

class VideoSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const VideoSettings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => ExpansionTile(
        leading: const Icon(Icons.ondemand_video),
        title: const Text(
          'Video',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          SwitchListTile.adaptive(
            title: const Text('Video'),
            value: settingsStore.showVideo,
            onChanged: (newValue) => settingsStore.showVideo = newValue,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Custom Video Overlay'),
            subtitle: const Text('Replaces the default video overlay with a mobile-friendly version.'),
            value: settingsStore.showOverlay,
            onChanged: settingsStore.showVideo ? (newValue) => settingsStore.showOverlay = newValue : null,
          ),
          if (Platform.isIOS)
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Picture-in-Picture Button (experimental)'),
              subtitle: const Text('Adds a button to enter PiP mode on the bottom right of the overlay. MAY CAUSE freezes/crashes.'),
              value: settingsStore.pictureInPicture,
              onChanged: settingsStore.showVideo && settingsStore.showOverlay ? (newValue) => settingsStore.pictureInPicture = newValue : null,
            ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Long-Press Player to Toggle Overlay'),
            subtitle: const Text('Allows switching between Twitch\'s default overlay and the custom video overlay.'),
            value: settingsStore.toggleableOverlay,
            onChanged: settingsStore.showVideo ? (newValue) => settingsStore.toggleableOverlay = newValue : null,
          ),
        ],
      ),
    );
  }
}

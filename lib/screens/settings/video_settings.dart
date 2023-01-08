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
      builder: (context) => ListView(
        children: [
          const SectionHeader('Player'),
          SwitchListTile.adaptive(
            title: const Text('Video'),
            value: settingsStore.showVideo,
            onChanged: (newValue) => settingsStore.showVideo = newValue,
          ),
          const SectionHeader('Overlay'),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Custom overlay'),
            subtitle: const Text('Replaces Twitch\'s default overlay with a mobile-friendly version.'),
            value: settingsStore.showOverlay,
            onChanged: settingsStore.showVideo ? (newValue) => settingsStore.showOverlay = newValue : null,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Long-press player to toggle overlay'),
            subtitle: const Text('Allows switching between Twitch\'s default overlay and the custom overlay.'),
            value: settingsStore.toggleableOverlay,
            onChanged: settingsStore.showVideo ? (newValue) => settingsStore.toggleableOverlay = newValue : null,
          ),
          const SizedBox(height: 15.0),
          ListTile(
            title: Row(
              children: [
                const Text('Custom overlay opacity'),
                const Spacer(),
                Text('${(settingsStore.overlayOpacity * 100).toStringAsFixed(0)}%'),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider.adaptive(
                  value: settingsStore.overlayOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (newValue) => settingsStore.overlayOpacity = newValue,
                ),
                const Text('Adjusts the opacity (transparency) of the stream overlay when active.'),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

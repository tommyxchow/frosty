import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_slider.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
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
          SettingsListSwitch(
            title: 'Video',
            value: settingsStore.showVideo,
            onChanged: (newValue) => settingsStore.showVideo = newValue,
          ),
          const SectionHeader('Overlay'),
          SettingsListSwitch(
            title: 'Custom overlay',
            subtitle: const Text('Replaces Twitch\'s default overlay with a mobile-friendly version.'),
            value: settingsStore.showOverlay,
            onChanged: (newValue) => settingsStore.showOverlay = newValue,
          ),
          SettingsListSwitch(
            title: 'Long-press player to toggle overlay',
            subtitle: const Text('Allows switching between Twitch\'s default overlay and the custom overlay.'),
            value: settingsStore.toggleableOverlay,
            onChanged: (newValue) => settingsStore.toggleableOverlay = newValue,
          ),
          const SizedBox(height: 15.0),
          SettingsListSlider(
            title: 'Custom overlay opacity',
            trailing: '${(settingsStore.overlayOpacity * 100).toStringAsFixed(0)}%',
            subtitle: 'Adjusts the opacity (transparency) of the stream overlay when active.',
            value: settingsStore.overlayOpacity,
            divisions: 10,
            onChanged: (newValue) => settingsStore.overlayOpacity = newValue,
          ),
        ],
      ),
    );
  }
}

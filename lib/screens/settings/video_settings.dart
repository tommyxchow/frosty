import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/screens/settings/widgets/settings_string_list_editor.dart';
import 'package:frosty/services/stream_proxy_config.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:frosty/widgets/settings_page_layout.dart';

class VideoSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const VideoSettings({super.key, required this.settingsStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => SettingsPageLayout(
        children: [
          const SectionHeader('Player', isFirst: true),
          SettingsListSwitch(
            title: 'Enable video',
            value: settingsStore.showVideo,
            onChanged: (newValue) => settingsStore.showVideo = newValue,
          ),
          if (!Platform.isIOS || isIPad())
            SettingsListSwitch(
              title: 'Default to highest quality',
              value: settingsStore.defaultToHighestQuality,
              onChanged: (newValue) =>
                  settingsStore.defaultToHighestQuality = newValue,
            ),
          if (Platform.isAndroid)
            SettingsListSwitch(
              title: 'Use fast video rendering',
              subtitle: const Text(
                'Uses a faster WebView rendering method. Disable if you experience crashes while watching streams.',
              ),
              value: settingsStore.useTextureRendering,
              onChanged: (newValue) =>
                  settingsStore.useTextureRendering = newValue,
            ),
          SettingsListSwitch(
            title: 'Keep screen awake',
            subtitle: const Text(
              'Prevents the screen from sleeping while a channel is open.',
            ),
            value: settingsStore.keepScreenAwake,
            onChanged: (newValue) => settingsStore.keepScreenAwake = newValue,
          ),
          if (Platform.isAndroid) ...[
            SettingsListSelect(
              title: 'Stream proxy mode',
              selectedOption:
                  streamProxyModeNames[settingsStore.streamProxyMode.index],
              options: streamProxyModeNames,
              onChanged: (selectedOption) {
                final selectedIndex = streamProxyModeNames.indexOf(
                  selectedOption,
                );
                if (selectedIndex == -1) return;

                settingsStore.streamProxyMode =
                    StreamProxyMode.values[selectedIndex];
              },
            ),
            if (settingsStore.streamProxyMode == StreamProxyMode.ttvLolPro) ...[
              SettingsStringListEditor(
                title: 'Proxy URLs',
                subtitle: 'Used for eligible livestream playback requests.',
                emptyMessage: 'No proxy URLs',
                hintText: 'proxy.example.com:3128',
                values: settingsStore.streamProxyUrls,
                validator: validateStreamProxyUrl,
                onChanged: (values) {
                  settingsStore.streamProxyUrls = values
                      .map((value) => value.trim())
                      .where((value) => value.isNotEmpty)
                      .toList();
                },
              ),
              SettingsStringListEditor(
                title: 'Whitelisted channels',
                subtitle: 'Channels that should always load direct.',
                emptyMessage: 'No whitelisted channels',
                hintText: 'streamer_name123',
                values: settingsStore.streamProxyWhitelistedChannels,
                validator: validateStreamProxyChannelLogin,
                normalizeValue: (value) => value.trim().toLowerCase(),
                onChanged: (values) {
                  settingsStore.streamProxyWhitelistedChannels = values
                      .map((value) => value.trim().toLowerCase())
                      .where((value) => value.isNotEmpty)
                      .toList();
                },
              ),
            ],
          ],
          const SectionHeader('Overlay'),
          SettingsListSwitch(
            title: 'Use custom video overlay',
            subtitle: const Text(
              'Replaces Twitch\'s default web overlay with a mobile-friendly version.',
            ),
            value: settingsStore.showOverlay,
            onChanged: (newValue) => settingsStore.showOverlay = newValue,
          ),
          SettingsListSwitch(
            title: 'Long-press player to toggle overlay',
            subtitle: const Text(
              'Allows switching between Twitch\'s overlay and the custom overlay.',
            ),
            value: settingsStore.toggleableOverlay,
            onChanged: (newValue) => settingsStore.toggleableOverlay = newValue,
          ),
          SettingsListSwitch(
            title: 'Show latency',
            subtitle: const Text(
              'Displays the stream latency in the video overlay.',
            ),
            value: settingsStore.showLatency,
            onChanged: (newValue) => settingsStore.showLatency = newValue,
          ),
        ],
      ),
    );
  }
}

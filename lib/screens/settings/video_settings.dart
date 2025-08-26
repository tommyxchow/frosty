import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_slider.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';
import 'package:frosty/widgets/section_header.dart';

class VideoSettings extends StatefulWidget {
  final SettingsStore settingsStore;

  const VideoSettings({super.key, required this.settingsStore});

  @override
  State<VideoSettings> createState() => _VideoSettingsState();
}

class _VideoSettingsState extends State<VideoSettings> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: 116,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            children: [
              const SectionHeader(
                'Player',
                isFirst: true,
              ),
              SettingsListSwitch(
                title: 'Enable video',
                value: widget.settingsStore.showVideo,
                onChanged: (newValue) =>
                    widget.settingsStore.showVideo = newValue,
              ),
              if (!Platform.isIOS || isIPad())
                SettingsListSwitch(
                  title: 'Default to highest quality',
                  value: widget.settingsStore.defaultToHighestQuality,
                  onChanged: (newValue) =>
                      widget.settingsStore.defaultToHighestQuality = newValue,
                ),
              if (Platform.isAndroid)
                SettingsListSwitch(
                  title: 'Use enhanced rendering',
                  subtitle: const Text(
                    'Enables a newer WebView rendering method that improves performance. May cause random crashes on some devices.',
                  ),
                  value: widget.settingsStore.useEnhancedRendering,
                  onChanged: (newValue) =>
                      widget.settingsStore.useEnhancedRendering = newValue,
                ),
              const SectionHeader('Overlay'),
              SettingsListSwitch(
                title: 'Use custom video overlay',
                subtitle: const Text(
                  'Replaces Twitch\'s default web overlay with a mobile-friendly version.',
                ),
                value: widget.settingsStore.showOverlay,
                onChanged: (newValue) =>
                    widget.settingsStore.showOverlay = newValue,
              ),
              SettingsListSwitch(
                title: 'Long-press player to toggle overlay',
                subtitle: const Text(
                  'Allows switching between Twitch\'s overlay and the custom overlay.',
                ),
                value: widget.settingsStore.toggleableOverlay,
                onChanged: (newValue) =>
                    widget.settingsStore.toggleableOverlay = newValue,
              ),
              SettingsListSlider(
                title: 'Custom overlay opacity',
                trailing:
                    '${(widget.settingsStore.overlayOpacity * 100).toStringAsFixed(0)}%',
                subtitle:
                    'Adjusts the opacity (transparency) of the custom video overlay when active.',
                value: widget.settingsStore.overlayOpacity,
                divisions: 10,
                onChanged: (newValue) =>
                    widget.settingsStore.overlayOpacity = newValue,
              ),
            ],
          ),
          Positioned(
            top: 108,
            left: 0,
            right: 0,
            child: AnimatedScrollBorder(
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}

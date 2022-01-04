import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';

class GeneralSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const GeneralSettings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('General'),
            SwitchListTile.adaptive(
              title: const Text('Use OLED theme'),
              subtitle: const Text('An all-black theme for OLED screens.'),
              value: settingsStore.useOledTheme,
              onChanged: (newValue) => settingsStore.useOledTheme = newValue,
            ),
            SwitchListTile.adaptive(
              title: const Text('Show stream uptime on thumbnails'),
              value: settingsStore.showThumbnailUptime,
              onChanged: (newValue) => settingsStore.showThumbnailUptime = newValue,
            ),
          ],
        );
      },
    );
  }
}

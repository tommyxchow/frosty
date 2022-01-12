import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';

class GeneralSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const GeneralSettings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const themes = ['System', 'Light', 'Dark', 'Black'];

    return Observer(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('General'),
            ListTile(
              title: const Text('Theme'),
              trailing: DropdownButton(
                value: settingsStore.themeType,
                onChanged: (ThemeType? newTheme) => settingsStore.themeType = newTheme!,
                items: ThemeType.values
                    .map((ThemeType value) => DropdownMenuItem(
                          value: value,
                          child: Text(themes[value.index]),
                        ))
                    .toList(),
              ),
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

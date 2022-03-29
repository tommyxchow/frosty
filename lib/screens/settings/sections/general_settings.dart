import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';

class GeneralSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const GeneralSettings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const themes = ['System', 'Light', 'Dark', 'Black'];

    return Observer(
      builder: (context) => ExpansionTile(
        leading: const Icon(Icons.settings),
        title: const Text(
          'General',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
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
            isThreeLine: true,
            title: const Text('Stream Uptime on Thumbnails'),
            subtitle: const Text('Displays the uptime of the stream in the HH:MM:SS format.'),
            value: settingsStore.showThumbnailUptime,
            onChanged: (newValue) => settingsStore.showThumbnailUptime = newValue,
          ),
        ],
      ),
    );
  }
}

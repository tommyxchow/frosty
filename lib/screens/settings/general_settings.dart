import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/widgets/section_header.dart';

class GeneralSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const GeneralSettings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const themes = ['System', 'Light', 'Dark', 'Black'];

    return Observer(
      builder: (context) => ListView(
        children: [
          const SectionHeader('Display'),
          SettingsListSelect(
            title: 'Theme',
            selectedOption: themes[settingsStore.themeType.index],
            options: themes,
            onChanged: (newTheme) => settingsStore.themeType = ThemeType.values[themes.indexOf(newTheme)],
          ),
          const SectionHeader('Stream card'),
          SettingsListSwitch(
            title: 'Large stream card',
            value: settingsStore.largeStreamCard,
            onChanged: (newValue) => settingsStore.largeStreamCard = newValue,
          ),
          SettingsListSwitch(
            title: 'Stream card thumbnails',
            value: settingsStore.showThumbnails,
            onChanged: (newValue) => settingsStore.showThumbnails = newValue,
          ),
          SettingsListSwitch(
            title: 'Stream uptime on thumbnails',
            subtitle: const Text('Shows the uptime of the stream in the HH:MM:SS format.'),
            value: settingsStore.showThumbnailUptime,
            onChanged: (newValue) => settingsStore.showThumbnailUptime = newValue,
          ),
          const SectionHeader('Links'),
          SettingsListSwitch(
            title: 'Launch URLs in external browser',
            subtitle: const Text('Opens links in the default external browser.'),
            value: settingsStore.launchUrlExternal,
            onChanged: (newValue) => settingsStore.launchUrlExternal = newValue,
          ),
        ],
      ),
    );
  }
}

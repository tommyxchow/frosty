import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/widgets/section_header.dart';

class GeneralSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const GeneralSettings({Key? key, required this.settingsStore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => ListView(
        children: [
          const SectionHeader('Display'),
          SettingsListSelect(
            title: 'Theme',
            selectedOption: themeNames[settingsStore.themeType.index],
            options: themeNames,
            onChanged: (newTheme) => settingsStore.themeType =
                ThemeType.values[themeNames.indexOf(newTheme)],
          ),
          const SectionHeader('Stream card'),
          SettingsListSwitch(
            title: 'Use large stream card',
            value: settingsStore.largeStreamCard,
            onChanged: (newValue) => settingsStore.largeStreamCard = newValue,
          ),
          SettingsListSwitch(
            title: 'Show thumbnail',
            value: settingsStore.showThumbnails,
            onChanged: (newValue) => settingsStore.showThumbnails = newValue,
          ),
          const SectionHeader('Links'),
          SettingsListSwitch(
            title: 'Open links in external browser',
            value: settingsStore.launchUrlExternal,
            onChanged: (newValue) => settingsStore.launchUrlExternal = newValue,
          ),
        ],
      ),
    );
  }
}

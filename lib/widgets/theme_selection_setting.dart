import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';

class ThemeSelectionSetting extends StatelessWidget {
  final SettingsStore settingsStore;

  const ThemeSelectionSetting({super.key, required this.settingsStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => SettingsListSelect(
        selectedOption: themeNames[settingsStore.themeType.index],
        options: themeNames,
        onChanged: (newTheme) => settingsStore.themeType =
            ThemeType.values[themeNames.indexOf(newTheme)],
      ),
    );
  }
}

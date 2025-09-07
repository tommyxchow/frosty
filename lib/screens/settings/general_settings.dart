import 'package:flutter/material.dart';
// import removed: flutter_colorpicker
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/widgets/accent_color_picker_dialog.dart';
// import removed: frosty/widgets/dialog.dart
import 'package:frosty/widgets/section_header.dart';
import 'package:frosty/widgets/settings_page_layout.dart';

class GeneralSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const GeneralSettings({super.key, required this.settingsStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => SettingsPageLayout(
        children: [
          const SectionHeader('Theme', isFirst: true),
          SettingsListSelect(
            selectedOption: themeNames[settingsStore.themeType.index],
            options: themeNames,
            onChanged: (newTheme) => settingsStore.themeType =
                ThemeType.values[themeNames.indexOf(newTheme)],
          ),
          ListTile(
            title: const Text('Accent color'),
            trailing: IconButton(
              icon: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Color(settingsStore.accentColor),
                  radius: 16,
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AccentColorPickerDialog(
                    initialColor: Color(settingsStore.accentColor),
                    onColorChanged: (newColor) =>
                        settingsStore.accentColor = newColor.toARGB32(),
                  ),
                );
              },
            ),
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

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:frosty/widgets/section_header.dart';

class GeneralSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const GeneralSettings({super.key, required this.settingsStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => ListView(
        padding: const EdgeInsets.only(top: 16),
        children: [
          const SectionHeader(
            'Theme',
            isFirst: true,
          ),
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
                  builder: (context) => FrostyDialog(
                    title: 'Accent color',
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: Color(settingsStore.accentColor),
                        onColorChanged: (newColor) =>
                            // TODO: Update when new method arrives in stable:
                            // https://github.com/flutter/flutter/issues/160184#issuecomment-2560184639
                            // ignore: deprecated_member_use
                            settingsStore.accentColor = newColor.value,
                        enableAlpha: false,
                        pickerAreaBorderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        labelTypes: const [],
                      ),
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
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

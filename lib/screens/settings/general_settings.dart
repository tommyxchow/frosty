import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/widgets/dialog.dart';
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
                  builder: (context) => _ColorPickerDialog(
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

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const _ColorPickerDialog({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
  }

  void _generateRandomColor() {
    HapticFeedback.mediumImpact();
    final random = Random();
    final newColor = Color.fromARGB(
      255, // Always full opacity
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
    setState(() {
      currentColor = newColor;
    });
    widget.onColorChanged(newColor);
  }

  @override
  Widget build(BuildContext context) {
    return FrostyDialog(
      title: 'Accent color',
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: currentColor,
          onColorChanged: (newColor) {
            setState(() {
              currentColor = newColor;
            });
            widget.onColorChanged(newColor);
          },
          enableAlpha: false,
          pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
          labelTypes: const [],
        ),
      ),
      actions: [
        FilledButton.tonal(
          onPressed: _generateRandomColor,
          child: const Text('Random'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

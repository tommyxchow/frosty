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
            const SectionHeader('GENERAL'),
            SwitchListTile.adaptive(
              title: const Text('OLED Theme'),
              value: settingsStore.oledTheme,
              onChanged: (newValue) => settingsStore.oledTheme = newValue,
            ),
          ],
        );
      },
    );
  }
}

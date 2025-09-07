import 'package:flutter/material.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';

class ExternalBrowserSetting extends StatelessWidget {
  final SettingsStore settingsStore;

  const ExternalBrowserSetting({super.key, required this.settingsStore});

  @override
  Widget build(BuildContext context) {
    return SettingsListSwitch(
      title: 'Open links in external browser',
      value: settingsStore.launchUrlExternal,
      onChanged: (newValue) => settingsStore.launchUrlExternal = newValue,
    );
  }
}

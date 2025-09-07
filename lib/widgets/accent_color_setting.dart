import 'package:flutter/material.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/accent_color_picker_dialog.dart';

class AccentColorSetting extends StatelessWidget {
  final SettingsStore settingsStore;

  const AccentColorSetting({super.key, required this.settingsStore});

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:frosty/widgets/frosty_dialog.dart';

class AccentColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const AccentColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<AccentColorPickerDialog> createState() =>
      _AccentColorPickerDialogState();
}

class _AccentColorPickerDialogState extends State<AccentColorPickerDialog> {
  late Color currentColor;
  static const Color defaultColor = Color(0xFF9246FE);

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
  }

  void _generateRandomColor() {
    HapticFeedback.lightImpact();
    final random = Random();
    final newColor = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    setState(() => currentColor = newColor);
    widget.onColorChanged(newColor);
  }
  void _resetToDefaultColor() {
    HapticFeedback.lightImpact();
    setState(() => currentColor = defaultColor);
    widget.onColorChanged(defaultColor);
  }

  @override
  Widget build(BuildContext context) {
    return FrostyDialog(
      title: 'Accent color',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (newColor) {
                setState(() => currentColor = newColor);
                widget.onColorChanged(newColor);
              },
              enableAlpha: false,
              pickerAreaBorderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              labelTypes: const [],
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.casino_rounded),
                    onPressed: _generateRandomColor,
                    label: const Text('Random'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _resetToDefaultColor,
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

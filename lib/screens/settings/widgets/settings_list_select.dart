import 'package:flutter/material.dart';

/// A custom-styled adaptive [ListTile] with options to select.
class SettingsListSelect extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String selectedOption;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const SettingsListSelect({
    super.key,
    this.title,
    this.subtitle,
    required this.selectedOption,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title != null ? Text(title!) : null,
      subtitle: Padding(
        padding: title != null
            ? const EdgeInsets.symmetric(vertical: 8)
            : EdgeInsets.zero,
        child: SegmentedButton(
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: options
              .map(
                (option) => ButtonSegment(
                  value: option,
                  label: Text(
                    option,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          selected: {selectedOption},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ),
    );
  }
}

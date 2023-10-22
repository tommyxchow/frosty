import 'package:flutter/material.dart';

/// A custom-styled adaptive [ListTile] with options to select.
class SettingsListSelect extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String selectedOption;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const SettingsListSelect({
    Key? key,
    required this.title,
    this.subtitle,
    required this.selectedOption,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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

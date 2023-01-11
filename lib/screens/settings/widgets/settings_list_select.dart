import 'package:flutter/material.dart';
import 'package:frosty/widgets/bottom_sheet.dart';

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
      isThreeLine: subtitle != null,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: SizedBox(
        height: double.infinity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(opacity: 0.8, child: Text(selectedOption)),
            const SizedBox(width: 5),
            Icon(Icons.adaptive.arrow_forward),
          ],
        ),
      ),
      onTap: () => showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (context) => FrostyBottomSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select ${title.toLowerCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ...options
                  .map((option) => ListTile(
                      title: Text(option),
                      trailing: selectedOption == option ? const Icon(Icons.check) : null,
                      onTap: () {
                        onChanged(option);
                        Navigator.of(context).pop();
                      }))
                  .toList()
            ],
          ),
        ),
      ),
    );
  }
}
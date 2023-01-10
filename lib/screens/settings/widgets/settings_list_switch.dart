import 'package:flutter/material.dart';

/// A custom-styled adaptive [SwitchListTile].
class SettingsListSwitch extends StatelessWidget {
  final String? title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsListSwitch({
    Key? key,
    this.title,
    this.subtitle,
    this.onChanged,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      isThreeLine: subtitle != null,
      title: Text(title!, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
    );
  }
}

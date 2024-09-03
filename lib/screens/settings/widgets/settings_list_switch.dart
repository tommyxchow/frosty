import 'package:flutter/material.dart';

/// A custom-styled adaptive [SwitchListTile].
class SettingsListSwitch extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsListSwitch({
    super.key,
    required this.title,
    this.subtitle,
    this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(title),
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
    );
  }
}

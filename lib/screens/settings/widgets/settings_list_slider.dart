import 'package:flutter/material.dart';

/// A custom-styled adaptive [Slider].
class SettingsListSlider extends StatelessWidget {
  final String title;
  final String trailing;
  final String? subtitle;
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;

  const SettingsListSlider({
    super.key,
    required this.title,
    required this.trailing,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(
            trailing,
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider.adaptive(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
            if (subtitle != null) Text(subtitle!),
          ],
        ),
      ),
    );
  }
}

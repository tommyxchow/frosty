import 'dart:ui';

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
    Key? key,
    required this.title,
    required this.trailing,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
  }) : super(key: key);

  static const _textStyle = TextStyle(fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      title: Row(
        children: [
          Text(title, style: _textStyle),
          const Spacer(),
          Text(trailing,
              style: _textStyle.copyWith(
                  fontFeatures: [const FontFeature.tabularFigures()])),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}

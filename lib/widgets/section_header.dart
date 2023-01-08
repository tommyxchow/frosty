import 'package:flutter/material.dart';
import 'package:frosty/main.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsets? padding;
  final double? fontSize;

  const SectionHeader(
    this.text, {
    Key? key,
    this.padding,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 30, 16, 5),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: purple,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

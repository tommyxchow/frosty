import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final double fontSize;
  final FontWeight fontWeight;

  const SectionHeader(
    this.text, {
    Key? key,
    this.padding = const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 5.0),
    this.fontSize = 12.0,
    this.fontWeight = FontWeight.bold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: DefaultTextStyle.of(context).style.color?.withOpacity(0.8),
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

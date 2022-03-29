import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final double fontSize;

  const SectionHeader(
    this.text, {
    Key? key,
    this.padding = const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 5.0),
    this.fontSize = 18.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

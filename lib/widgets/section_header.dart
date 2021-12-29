import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsets padding;

  const SectionHeader(
    this.text, {
    Key? key,
    this.padding = const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 5.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

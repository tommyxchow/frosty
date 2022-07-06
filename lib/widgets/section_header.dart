import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsets? padding;
  final double? fontSize;
  final bool showDivider;

  const SectionHeader(
    this.text, {
    Key? key,
    this.padding,
    this.fontSize,
    this.showDivider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          if (showDivider)
            const Divider(
              height: 10.0,
              thickness: 1.0,
            ),
        ],
      ),
    );
  }
}

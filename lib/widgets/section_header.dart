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
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showDivider) ...[
            const SizedBox(height: 8),
            const Divider(),
          ],
        ],
      ),
    );
  }
}

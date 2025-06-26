import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsets? padding;
  final double? fontSize;
  final bool isFirst;

  const SectionHeader(
    this.text, {
    super.key,
    this.padding,
    this.fontSize,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          (isFirst
              ? const EdgeInsets.fromLTRB(16, 16, 16, 8)
              : const EdgeInsets.fromLTRB(16, 32, 16, 8)),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize ?? 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

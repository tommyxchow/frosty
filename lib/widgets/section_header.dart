import 'package:flutter/material.dart';
import 'package:frosty/utils/context_extensions.dart';

class SectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsets? padding;
  final double? fontSize;
  final bool isFirst;
  final double? topPadding;

  const SectionHeader(
    this.text, {
    super.key,
    this.padding,
    this.fontSize,
    this.isFirst = false,
    this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          EdgeInsets.fromLTRB(
            16 + MediaQuery.of(context).padding.left,
            0,
            16 + MediaQuery.of(context).padding.right,
            8,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFirst) ...[SizedBox(height: topPadding ?? 32)],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: context.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

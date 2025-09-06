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
    final isLandscape = context.isLandscape;

    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(
            isLandscape ? MediaQuery.of(context).padding.left : 16,
            0,
            isLandscape ? MediaQuery.of(context).padding.right : 16,
            8,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isFirst) ...[
            SizedBox(height: topPadding ?? 32),
          ],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize ?? 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

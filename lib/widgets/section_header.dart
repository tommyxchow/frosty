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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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
            const SizedBox(height: 32),
          ],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: fontSize ?? 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

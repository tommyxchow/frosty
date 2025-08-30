import 'package:flutter/material.dart';
import 'package:frosty/utils/context_extensions.dart';

class ExpandableSectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsets? padding;
  final double? fontSize;
  final bool isFirst;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const ExpandableSectionHeader(
    this.text, {
    super.key,
    this.padding,
    this.fontSize,
    this.isFirst = false,
    required this.isExpanded,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = context.isLandscape;

    return InkWell(
      onTap: onToggle,
      child: Padding(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    text.toUpperCase(),
                    style: TextStyle(
                      fontSize: fontSize ?? 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

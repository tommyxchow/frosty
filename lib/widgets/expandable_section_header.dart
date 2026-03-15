import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return InkWell(
      onTap: onToggle != null
          ? () {
              HapticFeedback.selectionClick();
              onToggle!();
            }
          : null,
      child: Padding(
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
            if (!isFirst) ...[const SizedBox(height: 32)],
            Row(
              children: [
                Expanded(
                  child: Text(
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
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
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

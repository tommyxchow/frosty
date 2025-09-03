import 'package:flutter/material.dart';
import 'package:frosty/widgets/section_header.dart';

/// A custom dialog that makes the title bold, puts the actions in a column, and adds a subtle border.
class FrostyDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;

  const FrostyDialog({
    super.key,
    this.actions,
    required this.title,
    this.message,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title,
              isFirst: true,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            content ?? Text(message!, textAlign: TextAlign.center),
            if (actions != null) ...[
              const SizedBox(height: 16),
              ...?actions?.map(
                (action) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 4),
                  child: action,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

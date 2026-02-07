import 'package:flutter/material.dart';

/// A custom dialog that makes the title bold, displays actions in a full-width row layout with 50/50 split for 2 buttons, and adds a subtle border.
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
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) Text(message!),
            ?content,
            if (actions != null) ...[
              const SizedBox(height: 16),
              Row(
                children: actions!.asMap().entries.map((entry) {
                  final action = entry.value;
                  final isLast = entry.key == actions!.length - 1;

                  if (actions!.length == 1) {
                    // Single button takes full width
                    return Expanded(child: action);
                  } else if (actions!.length == 2) {
                    // Two buttons take 50% each
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 8),
                        child: action,
                      ),
                    );
                  } else {
                    // More than 2 buttons - distribute evenly with padding
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 8),
                        child: action,
                      ),
                    );
                  }
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

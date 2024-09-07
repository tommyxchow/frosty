import 'package:flutter/material.dart';

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
      title: Text(
        title,
        // style: const TextStyle(fontWeight: FontWeight.bold),
        // textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
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

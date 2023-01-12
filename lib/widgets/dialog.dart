import 'package:flutter/material.dart';

/// A custom dialog that makes the title bold, puts the actions in a column, and adds a subtle border.
class FrostyDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;

  const FrostyDialog({
    Key? key,
    this.actions,
    required this.title,
    this.message,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
      contentPadding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(children: [
          content ?? Text(message!, textAlign: TextAlign.center),
          if (actions != null) ...[
            const SizedBox(height: 25.0),
            ...?actions?.map(
              (action) => Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 5.0),
                child: action,
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

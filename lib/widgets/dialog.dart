import 'package:flutter/material.dart';

/// A custom dialog that makes the title bold, puts the actions in a column, and adds a subtle border.
class FrostyDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const FrostyDialog({
    Key? key,
    this.actions,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 20.0),
      contentPadding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(children: [
          content,
          if (actions != null) ...[
            const SizedBox(height: 20.0),
            ...?actions?.map(
              (action) => Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10.0),
                child: action,
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

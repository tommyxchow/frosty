import 'package:flutter/material.dart';

class FrostyNotification extends StatelessWidget {
  final String message;
  final bool showPasteButton;
  final Function() onButtonPressed;

  const FrostyNotification({
    super.key,
    required this.message,
    required this.showPasteButton,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showPasteButton)
            TextButton(
              onPressed: onButtonPressed,
              child: const Text('Paste'),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FrostyNotification extends StatelessWidget {
  final String message;
  final bool showPasteButton;
  final Function() onButtonPressed;

  const FrostyNotification({
    Key? key,
    required this.message,
    required this.showPasteButton,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(100),
      ),
      margin: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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

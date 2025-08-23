import 'package:flutter/material.dart';

class FrostyNotification extends StatelessWidget {
  final String message;
  final VoidCallback? onDismissed;

  const FrostyNotification({
    super.key,
    required this.message,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final Widget notificationContent = Container(
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
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onDismissed != null)
            IconButton(
              onPressed: onDismissed,
              icon: const Icon(Icons.close_rounded, size: 20),
              visualDensity: VisualDensity.compact,
              tooltip: 'Dismiss',
            ),
        ],
      ),
    );

    // Make it dismissible with swipe gesture if onDismissed is provided
    if (onDismissed != null) {
      return Dismissible(
        key: ValueKey(message),
        onDismissed: (_) => onDismissed!(),
        child: notificationContent,
      );
    }

    return notificationContent;
  }
}

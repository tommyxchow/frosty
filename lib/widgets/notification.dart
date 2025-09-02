import 'package:flutter/material.dart';
import 'package:frosty/widgets/blurred_container.dart';

class FrostyNotification extends StatelessWidget {
  final String message;
  final VoidCallback? onDismissed;
  final bool showGradient;

  const FrostyNotification({
    super.key,
    required this.message,
    this.onDismissed,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget notificationContent = BlurredContainer(
      gradientDirection:
          showGradient ? GradientDirection.up : GradientDirection.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                ),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onDismissed != null)
            IconButton(
              onPressed: onDismissed,
              icon: const Icon(Icons.close_rounded, size: 20),
              visualDensity: VisualDensity.compact,
              tooltip: 'Dismiss',
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.6),
            ),
        ],
      ),
    );

    // Make it dismissible with swipe gesture if onDismissed is provided
    if (onDismissed != null) {
      return Dismissible(
        key: ValueKey(message),
        onDismissed: (_) => onDismissed!(),
        direction: DismissDirection.up,
        child: notificationContent,
      );
    }

    return notificationContent;
  }
}

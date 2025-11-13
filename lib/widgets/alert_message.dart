import 'package:flutter/material.dart';

/// A simple widget that displays an alert message in the center.
class AlertMessage extends StatelessWidget {
  final String message;
  final Color? color;
  final bool centered;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingIconPressed;

  const AlertMessage({
    super.key,
    required this.message,
    this.centered = true,
    this.color,
    this.trailingIcon,
    this.onTrailingIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: color ?? defaultColor,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            message,
            style: TextStyle(
              color: color ?? defaultColor,
            ),
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              trailingIcon,
              color: color ?? defaultColor,
            ),
            onPressed: onTrailingIconPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 20,
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// A simple widget that displays an alert message in the center.
class AlertMessage extends StatelessWidget {
  final String message;
  final Color? color;
  final bool centered;
  final EdgeInsetsGeometry? padding;
  final bool vertical;

  const AlertMessage({
    super.key,
    required this.message,
    this.centered = true,
    this.color,
    this.padding,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    final Widget widget;

    if (vertical) {
      widget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: color ?? defaultColor,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: color ?? defaultColor,
            ),
          ),
        ],
      );
    } else {
      widget = Row(
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
        ],
      );
    }

    final effectivePadding = padding ??
        (vertical ? const EdgeInsets.symmetric(horizontal: 24) : null);

    return effectivePadding != null
        ? Padding(
            padding: effectivePadding,
            child: widget,
          )
        : widget;
  }
}

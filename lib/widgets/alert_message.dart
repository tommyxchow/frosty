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
    final defaultColor = Theme.of(context).colorScheme.onSurface;

    final Widget widget;

    if (vertical) {
      widget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(Icons.info_outline_rounded, color: color ?? defaultColor),
          Text(
            message,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(color: color ?? defaultColor),
          ),
        ],
      );
    } else {
      widget = Row(
        mainAxisAlignment: centered
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        spacing: 8,
        children: [
          Icon(Icons.info_outline_rounded, color: color ?? defaultColor),
          Flexible(
            child: Text(
              message,
              style: TextStyle(color: color ?? defaultColor),
            ),
          ),
        ],
      );
    }

    final effectivePadding =
        padding ??
        (vertical ? const EdgeInsets.symmetric(horizontal: 24) : null);

    return effectivePadding != null
        ? Padding(padding: effectivePadding, child: widget)
        : widget;
  }
}

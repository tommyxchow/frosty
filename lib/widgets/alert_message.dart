import 'package:flutter/material.dart';

/// A simple widget that displays an alert message in the center.
class AlertMessage extends StatelessWidget {
  final String message;
  final Color? color;
  final bool centered;

  const AlertMessage({
    super.key,
    required this.message,
    this.centered = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: color ?? Colors.grey,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

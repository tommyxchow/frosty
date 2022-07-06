import 'package:flutter/material.dart';

/// A simple widget that displays an alert message in the center.
class AlertMessage extends StatelessWidget {
  final String message;
  final IconData icon;

  const AlertMessage({
    Key? key,
    required this.message,
    final this.icon = Icons.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.grey,
        ),
        const SizedBox(width: 5.0),
        Flexible(
          child: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

/// A simple widget that displays an alert message in the center.
class AlertMessage extends StatelessWidget {
  final String message;
  final Color? color;

  const AlertMessage({
    Key? key,
    required this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeroIcon(
          HeroIcons.informationCircle,
          color: color ?? Colors.grey,
        ),
        const SizedBox(width: 5.0),
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

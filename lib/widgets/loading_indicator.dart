import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? subtitle;
  final double spacing;

  const LoadingIndicator({super.key, this.subtitle, this.spacing = 8});

  @override
  Widget build(BuildContext context) {
    if (subtitle == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator.adaptive(),
        SizedBox(height: spacing),
        Text(
          subtitle!,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

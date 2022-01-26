import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Widget? subtitle;
  final double spacing;

  const LoadingIndicator({Key? key, this.subtitle, this.spacing = 10.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (subtitle == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          SizedBox(height: spacing),
          subtitle!,
        ],
      ),
    );
  }
}

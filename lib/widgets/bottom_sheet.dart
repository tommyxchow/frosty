import 'package:flutter/material.dart';

class FrostyBottomSheet extends StatelessWidget {
  final Widget child;

  const FrostyBottomSheet({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FractionallySizedBox(
            widthFactor: 0.1,
            child: Divider(
              height: 30.0,
              thickness: 2.0,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

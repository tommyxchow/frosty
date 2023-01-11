import 'package:flutter/material.dart';

class FrostyBottomSheet extends StatelessWidget {
  final Widget child;

  const FrostyBottomSheet({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FractionallySizedBox(
              widthFactor: 0.2,
              child: SizedBox(
                child: Divider(
                  height: 30.0,
                  thickness: 2.0,
                ),
              ),
            ),
            Material(child: child),
          ],
        ),
      ),
    );
  }
}

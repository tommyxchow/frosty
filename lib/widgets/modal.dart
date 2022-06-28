import 'package:flutter/material.dart';

class FrostyModal extends StatelessWidget {
  final Widget child;

  const FrostyModal({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FractionallySizedBox(
              widthFactor: 0.25,
              child: SizedBox(
                child: Divider(
                  height: 25.0,
                  thickness: 3.0,
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

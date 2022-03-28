import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollToTopButton extends StatelessWidget {
  final ScrollController scrollController;

  const ScrollToTopButton({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Scroll to Top',
      preferBelow: false,
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          scrollController.animateTo(
            0.0,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 500),
          );
        },
        child: const Icon(Icons.keyboard_arrow_up),
        mini: true,
        heroTag: null,
      ),
    );
  }
}

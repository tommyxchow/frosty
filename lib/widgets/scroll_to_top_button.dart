import 'package:flutter/material.dart';
import 'package:frosty/widgets/button.dart';

class ScrollToTopButton extends StatelessWidget {
  final ScrollController scrollController;

  const ScrollToTopButton({Key? key, required this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: 'Scroll to top',
        preferBelow: false,
        child: Button(
          round: true,
          onPressed: () => scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
          ),
          padding: const EdgeInsets.all(16),
          child: const Icon(Icons.arrow_upward_rounded),
        ),
      ),
    );
  }
}

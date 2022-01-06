import 'package:flutter/material.dart';

class ScrollToTopButton extends StatelessWidget {
  final ScrollController scrollController;

  const ScrollToTopButton({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: const Text('Scroll to Top'),
      onPressed: () => scrollController.animateTo(
        0.0,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 500),
      ),
      icon: const Icon(
        Icons.arrow_circle_up,
      ),
    );
  }
}

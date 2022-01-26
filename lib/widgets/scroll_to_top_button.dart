import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScrollToTopButton extends StatelessWidget {
  final ScrollController scrollController;

  const ScrollToTopButton({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Scroll to top',
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
        child: const FaIcon(Icons.arrow_drop_up),
        mini: true,
        heroTag: null,
      ),
    );
  }
}

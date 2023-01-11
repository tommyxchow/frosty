import 'package:flutter/material.dart';
import 'package:frosty/widgets/button.dart';
import 'package:heroicons/heroicons.dart';

class ScrollToTopButton extends StatelessWidget {
  final ScrollController scrollController;

  const ScrollToTopButton({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Tooltip(
        message: 'Scroll to top',
        preferBelow: false,
        child: Button(
          onPressed: () => scrollController.animateTo(
            0.0,
            curve: Curves.easeOutCubic,
            duration: const Duration(milliseconds: 500),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: const HeroIcon(HeroIcons.chevronDoubleUp, style: HeroIconStyle.mini),
        ),
      ),
    );
  }
}

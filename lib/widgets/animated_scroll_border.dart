import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AnimatedScrollBorder extends HookWidget {
  final ScrollController scrollController;

  const AnimatedScrollBorder({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isScrolled = useState(false);

    void updateScrollState() {
      isScrolled.value = scrollController.offset > 0;
    }

    useEffect(
      () {
        scrollController.addListener(updateScrollState);
        return () => scrollController.removeListener(updateScrollState);
      },
      [scrollController],
    );

    return AnimatedSwitcher(
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      duration: const Duration(milliseconds: 200),
      child: isScrolled.value
          ? const Divider()
          : Divider(
              key: ValueKey(isScrolled.value),
              color: Colors.transparent,
            ),
    );
  }
}

import 'package:flutter/material.dart';

class AnimatedScrollBorder extends StatefulWidget {
  final ScrollController scrollController;

  const AnimatedScrollBorder({
    super.key,
    required this.scrollController,
  });

  @override
  State<AnimatedScrollBorder> createState() => _AnimatedScrollBorderState();
}

class _AnimatedScrollBorderState extends State<AnimatedScrollBorder> {
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateScrollState);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScrollState);
    super.dispose();
  }

  void _updateScrollState() {
    setState(() {
      _isScrolled = widget.scrollController.offset > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      duration: const Duration(milliseconds: 200),
      child: _isScrolled
          ? const Divider()
          : Divider(
              key: ValueKey(_isScrolled),
              color: Colors.transparent,
            ),
    );
  }
}

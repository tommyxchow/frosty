import 'package:flutter/material.dart';

/// A widget than animates its scale when tapped/held on.
class AnimateScale extends StatefulWidget {
  final void Function()? onTap;
  final void Function()? onLongPress;
  final Widget child;

  const AnimateScale({
    Key? key,
    this.onTap,
    this.onLongPress,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimateScale> createState() => _AnimateScaleState();
}

class _AnimateScaleState extends State<AnimateScale> with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    upperBound: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 200);
    const downCurve = Curves.easeOutCubic;
    const upCurve = Curves.easeInCubic;

    return InkWell(
      onTap: widget.onTap,
      onTapDown: (_) => _animationController.animateTo(
        _animationController.upperBound,
        curve: downCurve,
        duration: duration,
      ),
      onLongPress: widget.onLongPress,
      onTapUp: (_) => _animationController.animateTo(
        _animationController.lowerBound,
        curve: upCurve,
        duration: duration,
      ),
      onTapCancel: () => _animationController.animateTo(
        _animationController.lowerBound,
        curve: upCurve,
        duration: duration,
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        child: widget.child,
        builder: (context, child) => Transform.scale(
          scale: 1 - _animationController.value,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

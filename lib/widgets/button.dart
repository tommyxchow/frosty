import 'dart:io';

import 'package:flutter/material.dart';

/// A custom button that scales down when tapped/held on (sorta like a real button).
class Button extends StatefulWidget {
  final Color? color;
  final bool fill;
  final EdgeInsets padding;
  final double? fontSize;
  final Widget? icon;
  final Function()? onPressed;
  final Widget child;

  const Button({
    Key? key,
    this.color,
    this.fill = false,
    this.padding = const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    this.fontSize,
    this.icon,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    upperBound: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: widget.fill ? null : widget.color,
      backgroundColor: widget.color == null || widget.fill ? widget.color : Colors.transparent,
      padding: widget.padding,
      splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
      textStyle: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.w600, fontSize: widget.fontSize),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: widget.color == null ? 10.0 : 0.0,
    ).copyWith(
      elevation: (widget.color == null || widget.fill) && widget.onPressed != null
          ? MaterialStateProperty.resolveWith(
              (states) {
                if (states.contains(MaterialState.pressed)) {
                  return 0.0;
                } else {
                  return 5.0;
                }
              },
            )
          : MaterialStateProperty.all(0.0),
    );

    final button = widget.icon == null
        ? ElevatedButton(
            style: buttonStyle,
            onPressed: widget.onPressed,
            child: widget.child,
          )
        : ElevatedButton.icon(
            style: buttonStyle,
            onPressed: widget.onPressed,
            icon: widget.icon!,
            label: widget.child,
          );

    const duration = Duration(milliseconds: 200);

    return AnimatedBuilder(
      animation: _animationController,
      child: widget.onPressed == null
          ? button
          : Listener(
              onPointerDown: (_) {
                if (mounted) {
                  _animationController.animateTo(
                    _animationController.upperBound,
                    curve: Curves.easeOut,
                    duration: duration,
                  );
                }
              },
              onPointerUp: (_) {
                if (mounted) {
                  _animationController.animateTo(
                    _animationController.lowerBound,
                    curve: Curves.easeIn,
                    duration: duration,
                  );
                }
              },
              onPointerCancel: (_) {
                if (mounted) {
                  _animationController.animateTo(
                    _animationController.lowerBound,
                    curve: Curves.easeIn,
                    duration: duration,
                  );
                }
              },
              child: button,
            ),
      builder: (context, child) => Transform.scale(
        scale: 1 - _animationController.value,
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

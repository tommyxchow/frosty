import 'package:flutter/material.dart';

class LiveIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const LiveIndicator({
    super.key,
    this.size = _LiveIndicatorState._defaultSize,
    this.color = Colors.red,
  });

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // CONFIGURABLE ANIMATION PARAMETERS
  // ===========================================================================

  // Animation timing
  static const Duration _animationDuration = Duration(milliseconds: 1000);

  // Size scaling
  static const double _defaultSize = 8.0;
  static const double _pingScaleStart = 1.0;
  static const double _pingScaleEnd = 2.5;

  // Opacity settings
  static const double _pingOpacityStart = 1.0;
  static const double _pingOpacityEnd = 0.0;

  // Visual appearance
  static const double _borderWidth = 2.5;
  static const double _borderOpacity = 0.8;

  // ===========================================================================
  // STATE VARIABLES
  // ===========================================================================

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _animationDuration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _PingPainter(
          animation: _controller,
          color: widget.color,
          scaleStart: _pingScaleStart,
          scaleEnd: _pingScaleEnd,
          opacityStart: _pingOpacityStart,
          opacityEnd: _pingOpacityEnd,
          borderWidth: _borderWidth,
          borderOpacity: _borderOpacity,
        ),
      ),
    );
  }
}

class _PingPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  final double scaleStart;
  final double scaleEnd;
  final double opacityStart;
  final double opacityEnd;
  final double borderWidth;
  final double borderOpacity;

  _PingPainter({
    required this.animation,
    required this.color,
    required this.scaleStart,
    required this.scaleEnd,
    required this.opacityStart,
    required this.opacityEnd,
    required this.borderWidth,
    required this.borderOpacity,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, baseRadius, dotPaint);

    final progress = Curves.easeOut.transform(animation.value);

    final currentScale = scaleStart + (scaleEnd - scaleStart) * progress;
    final currentOpacity =
        opacityStart + (opacityEnd - opacityStart) * progress;

    if (currentOpacity > 0) {
      final pingRadius = baseRadius * currentScale;

      final borderPaint = Paint()
        ..color = color.withValues(alpha: currentOpacity * borderOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      canvas.drawCircle(center, pingRadius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.animation != animation;
  }
}

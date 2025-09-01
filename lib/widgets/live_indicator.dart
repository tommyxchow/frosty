import 'package:flutter/material.dart';

/// A live indicator widget that displays a red dot with a ping animation.
/// Used to indicate when a channel or stream is currently live.
class LiveIndicator extends StatefulWidget {
  /// The size of the indicator dot.
  final double size;

  /// The color of the indicator. Defaults to red.
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
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

  AnimationController? _pingController;
  Animation<double>? _pingScale;
  Animation<double>? _pingOpacity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAnimations();
  }

  @override
  void didUpdateWidget(LiveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize animations if widget properties changed during hot reload
    if (oldWidget.size != widget.size || oldWidget.color != widget.color) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  void _initAnimations() {
    _pingController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    )..repeat();

    _pingScale = Tween<double>(
      begin: _pingScaleStart,
      end: _pingScaleEnd,
    ).animate(
      CurvedAnimation(
        parent: _pingController!,
        curve: Curves.easeOut,
      ),
    );

    _pingOpacity = Tween<double>(
      begin: _pingOpacityStart,
      end: _pingOpacityEnd,
    ).animate(
      CurvedAnimation(
        parent: _pingController!,
        curve: Curves.easeOut,
      ),
    );
  }

  void _disposeAnimations() {
    _pingController?.dispose();
    _pingController = null;
    _pingScale = null;
    _pingOpacity = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAnimations();
    super.dispose();
  }

  // Ensure animations refresh properly during hot reload/hot restart in debug.
  @override
  void reassemble() {
    super.reassemble();
    _disposeAnimations();
    _initAnimations();
  }

  // Handle app lifecycle (e.g., returning from background) to keep animation running.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_pingController == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_pingController!.isAnimating) {
          _pingController!.repeat();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _pingController!.stop();
        break;
      case AppLifecycleState.hidden:
        _pingController!.stop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle case where animations aren't initialized (hot reload issue)
    if (_pingController == null || _pingScale == null || _pingOpacity == null) {
      _initAnimations();
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pingController!,
      builder: (context, child) {
        final pingSize = widget.size * _pingScale!.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Ping ring rendered outside without affecting layout
              Positioned.fill(
                child: IgnorePointer(
                  child: OverflowBox(
                    maxWidth: pingSize,
                    maxHeight: pingSize,
                    child: Center(
                      child: Opacity(
                        opacity: _pingOpacity!.value,
                        child: Container(
                          width: pingSize,
                          height: pingSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.color
                                  .withValues(alpha: _borderOpacity),
                              width: _borderWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Static center dot
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

enum ScrollBorderPosition { top, bottom }

class AnimatedScrollBorder extends StatefulWidget {
  final ScrollController scrollController;
  final ScrollBorderPosition position;
  final bool isReversed; // For lists with reverse: true

  const AnimatedScrollBorder({
    super.key,
    required this.scrollController,
    this.position = ScrollBorderPosition.top,
    this.isReversed = false,
  });

  @override
  State<AnimatedScrollBorder> createState() => _AnimatedScrollBorderState();
}

class _AnimatedScrollBorderState extends State<AnimatedScrollBorder> {
  bool _shouldShowBorder = false;

  @override
  void initState() {
    super.initState();
    // Default to visible for bottom borders until we know we're at the end
    if (widget.position == ScrollBorderPosition.bottom) {
      _shouldShowBorder = true;
    }
    widget.scrollController.addListener(_updateScrollState);
    _updateScrollState(); // Initial check
    // Also check after a frame to ensure scroll controller is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollState();
    });
  }

  @override
  void didUpdateWidget(AnimatedScrollBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      oldWidget.scrollController.removeListener(_updateScrollState);
      widget.scrollController.addListener(_updateScrollState);
      _updateScrollState(); // Initial check for new controller
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateScrollState);
    super.dispose();
  }

  void _updateScrollState() {
    if (!mounted) return;

    bool shouldShow = false;

    if (widget.position == ScrollBorderPosition.top) {
      // Show border when scrolled away from top.
      if (!widget.scrollController.hasClients) {
        shouldShow = false;
      } else {
        // Safely access position to handle ScrollController state transitions
        final ScrollPosition? pos;
        try {
          pos = widget.scrollController.position;
        } catch (e) {
          // ScrollController might be attached to multiple scroll views during rebuilds
          shouldShow = false;
          if (shouldShow != _shouldShowBorder) {
            setState(() {
              _shouldShowBorder = shouldShow;
            });
          }
          return;
        }
        final bool hasDims = pos.hasPixels && pos.haveDimensions;
        if (!hasDims) {
          shouldShow = false;
        } else if (!widget.isReversed) {
          shouldShow = pos.pixels > 0;
        } else {
          // For reversed lists, the visual "top" corresponds to maxScrollExtent.
          final bool noScrollExtent = pos.maxScrollExtent <= 0.5;
          if (noScrollExtent) {
            shouldShow = false;
          } else {
            final bool reachedTop = pos.pixels >= (pos.maxScrollExtent - 1.0);
            shouldShow = !reachedTop;
          }
        }
      }
    } else {
      // Bottom border: default visible, hide only when we've reached the end
      if (!widget.scrollController.hasClients) {
        shouldShow = true; // default visible before attachment/first layout
      } else {
        // Safely access position to handle ScrollController state transitions
        final ScrollPosition? pos;
        try {
          pos = widget.scrollController.position;
        } catch (e) {
          // ScrollController might be attached to multiple scroll views during rebuilds
          shouldShow = true; // default to visible for bottom border
          if (shouldShow != _shouldShowBorder) {
            setState(() {
              _shouldShowBorder = shouldShow;
            });
          }
          return;
        }
        final bool hasDims = pos.hasPixels && pos.haveDimensions;
        if (!hasDims) {
          shouldShow = true; // keep visible until dimensions are known
        } else {
          // If there is no scrollable extent, keep it visible (default)
          final bool noScrollExtent = pos.maxScrollExtent <= 0.5;
          if (noScrollExtent) {
            shouldShow = true;
          } else {
            // Hide only when we're essentially at the end
            final bool reachedEnd = pos.pixels >= (pos.maxScrollExtent - 1.0);
            shouldShow = !reachedEnd;
          }
        }
      }
    }

    if (shouldShow != _shouldShowBorder) {
      setState(() {
        _shouldShowBorder = shouldShow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      duration: const Duration(milliseconds: 200),
      child: _shouldShowBorder
          ? const Divider()
          : Divider(
              key: ValueKey(_shouldShowBorder),
              color: Colors.transparent,
            ),
    );
  }
}

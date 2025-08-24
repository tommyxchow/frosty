import 'dart:math';

import 'package:flutter/material.dart';

/// A skeleton loading widget that displays a pulsing placeholder
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    // Make skeleton more visible in dark mode
    final baseColor = brightness == Brightness.dark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainer;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

/// A skeleton loader with random width for text placeholders
class SkeletonText extends StatelessWidget {
  final double height;
  final double? minWidth;
  final double? maxWidth;
  final BorderRadius? borderRadius;

  const SkeletonText({
    super.key,
    required this.height,
    this.minWidth,
    this.maxWidth,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate random width based on provided constraints or reasonable defaults
    final min = minWidth ?? screenWidth * 0.3;
    final max = maxWidth ?? screenWidth * 0.8;
    final randomWidth = min + random.nextDouble() * (max - min);

    return SkeletonLoader(
      width: randomWidth,
      height: height,
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(4)),
    );
  }
}

/// A skeleton loader for channel list items
class ChannelSkeletonLoader extends StatelessWidget {
  final bool showSubtitle;
  final int index;

  const ChannelSkeletonLoader({
    super.key,
    this.showSubtitle = true,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Show subtitle for first 3-4 items (simulating live channels at top)
    // then single line for the rest
    final shouldShowSubtitle = showSubtitle && index < 4;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const SkeletonLoader(
        width: 32,
        height: 32,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      title: SkeletonText(
        height: 16,
        minWidth: 60,
        maxWidth: 140,
      ),
      subtitle: shouldShowSubtitle
          ? SkeletonText(
              height: 14,
              minWidth: 30,
              maxWidth: 80,
            )
          : null,
    );
  }
}

/// A skeleton loader for category list items
class CategorySkeletonLoader extends StatelessWidget {
  const CategorySkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: 16 + MediaQuery.of(context).padding.left,
        right: 16 + MediaQuery.of(context).padding.right,
      ),
      child: Row(
        children: [
          // Category box art skeleton (3:4 aspect ratio, 80px wide)
          SizedBox(
            width: 80,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: const SkeletonLoader(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Category name skeleton with random width (matches bodyLarge text)
          Flexible(
            child: SkeletonText(
              height: 18,
              minWidth: 80,
              maxWidth: 180,
            ),
          ),
        ],
      ),
    );
  }
}

/// A skeleton loader for stream cards with thumbnail
class StreamCardSkeletonLoader extends StatelessWidget {
  final bool showThumbnail;
  final bool showCategory;

  const StreamCardSkeletonLoader({
    super.key,
    this.showThumbnail = true,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: showThumbnail ? 16 : 4,
      ),
      child: Row(
        children: [
          if (showThumbnail) ...[
            // Thumbnail skeleton (16:9 aspect ratio)
            Flexible(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: const SkeletonLoader(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ],
          // Stream info skeleton
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streamer name row
                  Row(
                    children: [
                      const SkeletonLoader(
                        width: 20,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: SkeletonText(
                          height: 16,
                          minWidth: 60,
                          maxWidth: 120,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Stream title skeleton with random width
                  SkeletonText(
                    height: 14,
                    minWidth: 100,
                    maxWidth: 200,
                  ),
                  if (showCategory) ...[
                    const SizedBox(height: 4),
                    // Category skeleton with random width
                    SkeletonText(
                      height: 14,
                      minWidth: 60,
                      maxWidth: 120,
                    ),
                  ],
                  const SizedBox(height: 4),
                  // Viewer count skeleton with random width
                  SkeletonText(
                    height: 14,
                    minWidth: 50,
                    maxWidth: 90,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A skeleton loader for large stream cards (grid layout)
class LargeStreamCardSkeletonLoader extends StatelessWidget {
  final bool showCategory;

  const LargeStreamCardSkeletonLoader({
    super.key,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail skeleton (16:9 aspect ratio)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: const SkeletonLoader(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          const SizedBox(height: 8),
          // Streamer info row with profile picture and name
          Row(
            children: [
              const SkeletonLoader(
                width: 56, // ProfilePicture radius 28 * 2
                height: 56,
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Streamer name skeleton with random width
                    SkeletonText(
                      height: 16,
                      minWidth: 80,
                      maxWidth: 150,
                    ),
                    const SizedBox(height: 4),
                    // Stream title skeleton with random width
                    SkeletonText(
                      height: 14,
                      minWidth: 120,
                      maxWidth: 200,
                    ),
                    if (showCategory) ...[
                      const SizedBox(height: 4),
                      // Category skeleton with random width
                      SkeletonText(
                        height: 14,
                        minWidth: 70,
                        maxWidth: 130,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

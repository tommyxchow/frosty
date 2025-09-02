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
        spacing: 16,
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
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: showThumbnail
            ? 16 + MediaQuery.of(context).padding.left
            : 4 + MediaQuery.of(context).padding.left,
        right: showThumbnail
            ? 16 + MediaQuery.of(context).padding.right
            : 4 + MediaQuery.of(context).padding.right,
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
                spacing: 8,
                children: [
                  // Streamer name row
                  Row(
                    spacing: 4,
                    children: [
                      const SkeletonLoader(
                        width: 20,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      Expanded(
                        child: SkeletonText(
                          height: 16,
                          minWidth: 60,
                          maxWidth: 120,
                        ),
                      ),
                    ],
                  ),
                  // Stream title skeleton with random width
                  SkeletonText(
                    height: 14,
                    minWidth: 100,
                    maxWidth: 200,
                  ),
                  if (showCategory) ...[
                    // Category skeleton with random width
                    SkeletonText(
                      height: 14,
                      minWidth: 60,
                      maxWidth: 120,
                    ),
                  ],
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
  final bool showThumbnail;
  final bool showCategory;

  const LargeStreamCardSkeletonLoader({
    super.key,
    this.showThumbnail = true,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: showThumbnail ? 12 : 4,
        bottom: showThumbnail ? 12 : 4,
        left: 16 + MediaQuery.of(context).padding.left,
        right: 16 + MediaQuery.of(context).padding.right,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showThumbnail) ...[
            // Thumbnail skeleton (16:9 aspect ratio)
            SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: const SkeletonLoader(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
          // Stream info bar skeleton
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              spacing: 12,
              children: [
                const SkeletonLoader(
                  width: 32, // ProfilePicture radius 16 * 2
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      // Top row: Streamer name + stream title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        spacing: 8,
                        children: [
                          // Streamer name skeleton
                          SkeletonText(
                            height: 14,
                            minWidth: 80,
                            maxWidth: 120,
                          ),
                          // Stream title skeleton (takes remaining space)
                          Flexible(
                            child: SkeletonText(
                              height: 14,
                              minWidth: 150,
                              maxWidth: 250,
                            ),
                          ),
                        ],
                      ),
                      // Bottom row: Live indicator, uptime, viewer count, game name
                      Row(
                        children: [
                          // Live indicator skeleton (8.0 default size)
                          const SkeletonLoader(
                            width: 8.0,
                            height: 8.0,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          const SizedBox(width: 6),
                          // Uptime skeleton
                          SkeletonText(
                            height: 14,
                            minWidth: 50,
                            maxWidth: 70,
                          ),
                          const SizedBox(width: 8),
                          // Viewer count icon skeleton
                          const SkeletonLoader(
                            width: 14,
                            height: 14,
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                          const SizedBox(width: 4),
                          // Viewer count text skeleton
                          SkeletonText(
                            height: 14,
                            minWidth: 50,
                            maxWidth: 80,
                          ),
                          if (showCategory) ...[
                            const SizedBox(width: 8),
                            // Category icon skeleton (gamepad)
                            const SkeletonLoader(
                              width: 14,
                              height: 14,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                            ),
                            const SizedBox(width: 4),
                            // Category text skeleton
                            Flexible(
                              child: SkeletonText(
                                height: 14,
                                minWidth: 80,
                                maxWidth: 140,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A skeleton loader for offline channel cards
class OfflineChannelCardSkeletonLoader extends StatelessWidget {
  const OfflineChannelCardSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 + MediaQuery.of(context).padding.left,
        vertical: 8,
      ),
      child: Row(
        spacing: 12,
        children: [
          // Profile picture skeleton (radius 24 = 48px diameter)
          const SkeletonLoader(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          // Channel info skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                // Channel name skeleton
                SkeletonText(
                  height: 16,
                  minWidth: 80,
                  maxWidth: 160,
                ),
                // Following duration skeleton
                SkeletonText(
                  height: 14,
                  minWidth: 100,
                  maxWidth: 140,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

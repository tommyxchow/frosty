import 'package:flutter/material.dart';
import 'package:frosty/utils/orientation_utils.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';

/// A reusable layout for settings pages that handles common functionality:
/// - Orientation detection
/// - Responsive padding calculations
/// - AnimatedScrollBorder positioning
/// - ScrollController management
class SettingsPageLayout extends StatefulWidget {
  final List<Widget> children;
  final bool hasBottomPadding;
  final EdgeInsetsGeometry? additionalPadding;
  final RefreshCallback? onRefresh;

  const SettingsPageLayout({
    super.key,
    required this.children,
    this.hasBottomPadding = true,
    this.additionalPadding,
    this.onRefresh,
  });

  @override
  State<SettingsPageLayout> createState() => _SettingsPageLayoutState();
}

class _SettingsPageLayoutState extends State<SettingsPageLayout> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = context.isPortrait;

    // Responsive values based on orientation
    final listPadding = EdgeInsets.only(
      top: isPortrait ? 116 : 92,
      bottom: widget.hasBottomPadding
          ? MediaQuery.of(context).padding.bottom + 8
          : 0,
    );

    final borderTop = isPortrait ? 108 : 84;

    final content = Stack(
      children: [
        ListView(
          controller: _scrollController,
          padding: widget.additionalPadding != null
              ? widget.additionalPadding!.add(listPadding)
              : listPadding,
          children: widget.children,
        ),
        Positioned(
          top: borderTop.toDouble(),
          left: 0,
          right: 0,
          child: AnimatedScrollBorder(
            scrollController: _scrollController,
          ),
        ),
      ],
    );

    // Conditionally wrap with RefreshIndicator if onRefresh is provided
    if (widget.onRefresh != null) {
      return RefreshIndicator.adaptive(
        onRefresh: widget.onRefresh!,
        child: content,
      );
    }

    return content;
  }
}

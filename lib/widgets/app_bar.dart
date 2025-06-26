import 'dart:ui';

import 'package:flutter/material.dart';

class FrostyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool showBackButton;

  const FrostyAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
          leading: showBackButton
              ? IconButton(
                  tooltip: 'Back',
                  icon: Icon(Icons.adaptive.arrow_back_rounded),
                  onPressed: Navigator.of(context).pop,
                )
              : null,
          title: title,
          actions: actions,
          centerTitle: false,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

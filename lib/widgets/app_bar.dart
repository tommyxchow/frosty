import 'package:flutter/material.dart';

class FrostyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final bool? centerTitle;
  final List<Widget>? actions;

  const FrostyAppBar({
    super.key,
    required this.title,
    this.centerTitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        tooltip: 'Back',
        icon: Icon(Icons.adaptive.arrow_back_rounded),
        onPressed: Navigator.of(context).pop,
      ),
      title: title,
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

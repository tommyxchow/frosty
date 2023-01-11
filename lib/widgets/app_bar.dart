import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class FrostyAppBar extends StatelessWidget with PreferredSizeWidget {
  final Widget title;
  final bool? centerTitle;
  final List<Widget>? actions;

  const FrostyAppBar({
    Key? key,
    required this.title,
    this.centerTitle,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        tooltip: 'Back',
        icon: const HeroIcon(
          HeroIcons.chevronLeft,
          style: HeroIconStyle.solid,
        ),
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

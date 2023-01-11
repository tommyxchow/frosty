import 'package:flutter/material.dart';

class FrostyListTile extends StatelessWidget {
  final bool? isThreeLine;
  final Widget? leading;
  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  const FrostyListTile({
    Key? key,
    this.isThreeLine,
    this.leading,
    required this.title,
    this.trailing,
    this.onTap,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: isThreeLine ?? subtitle != null,
      leading: leading,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

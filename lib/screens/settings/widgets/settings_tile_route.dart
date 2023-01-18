import 'package:flutter/material.dart';
import 'package:frosty/widgets/app_bar.dart';

class SettingsTileRoute extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget child;

  const SettingsTileRoute({
    Key? key,
    required this.leading,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: FrostyAppBar(title: Text(title)),
            body: child,
          ),
        ),
      ),
    );
  }
}

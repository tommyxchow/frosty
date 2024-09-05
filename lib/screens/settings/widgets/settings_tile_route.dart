import 'package:flutter/material.dart';
import 'package:frosty/widgets/app_bar.dart';

class SettingsTileRoute extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget child;
  final bool useScaffold;

  const SettingsTileRoute({
    super.key,
    required this.leading,
    required this.title,
    required this.child,
    this.useScaffold = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => useScaffold
              ? Scaffold(
                  appBar: FrostyAppBar(title: Text(title)),
                  body: SafeArea(
                    bottom: false,
                    child: child,
                  ),
                )
              : child,
        ),
      ),
    );
  }
}

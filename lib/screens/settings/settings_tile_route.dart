import 'package:flutter/material.dart';

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
      title: Text(title),
      trailing: Icon(Icons.adaptive.arrow_forward),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(title)),
            body: child,
          ),
        ),
      ),
    );
  }
}

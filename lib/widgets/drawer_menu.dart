import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/screens/settings.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text('Frosty for Twitch'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return const Settings();
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

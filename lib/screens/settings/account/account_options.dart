import 'package:flutter/material.dart';
import 'package:frosty/screens/settings/account/blocked_users.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/widgets/settings_tile_route.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';

class AccountOptions extends StatelessWidget {
  final AuthStore authStore;

  const AccountOptions({Key? key, required this.authStore}) : super(key: key);

  Future<void> _showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Log Out',
        content: const Text('Are you sure you want to log out?'),
        actions: [
          Button(
            onPressed: () {
              authStore.logout();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
          Button(
            fill: true,
            onPressed: Navigator.of(context).pop,
            color: Colors.red.shade700,
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SettingsTileRoute(
          leading: const Icon(Icons.person_off),
          title: 'Blocked',
          child: BlockedUsers(
            authStore: authStore,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w600)),
          trailing: Icon(Icons.adaptive.arrow_forward),
          onTap: () => _showLogoutDialog(context),
        )
      ],
    );
  }
}

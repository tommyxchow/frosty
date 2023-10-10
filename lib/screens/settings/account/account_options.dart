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
        message: 'Are you sure you want to log out?',
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
            onPressed: Navigator.of(context).pop,
            color: Colors.grey,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SettingsTileRoute(
          leading: const Icon(Icons.block_rounded),
          title: 'Blocked',
          child: BlockedUsers(
            authStore: authStore,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.logout_rounded),
          title: const Text('Log out'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }
}

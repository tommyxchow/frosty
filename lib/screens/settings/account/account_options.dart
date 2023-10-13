import 'package:flutter/material.dart';
import 'package:frosty/screens/settings/account/blocked_users.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/widgets/settings_tile_route.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:frosty/widgets/section_header.dart';

class AccountOptions extends StatelessWidget {
  final AuthStore authStore;

  const AccountOptions({Key? key, required this.authStore}) : super(key: key);

  Future<void> _showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Log out',
        message: 'Are you sure you want to log out?',
        actions: [
          FilledButton(
            onPressed: () {
              authStore.logout();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      primary: false,
      children: [
        const SectionHeader(
          'Account',
          padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
        ),
        SettingsTileRoute(
          leading: const Icon(Icons.block_rounded),
          title: 'Blocked users',
          child: BlockedUsers(
            authStore: authStore,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.logout_rounded),
          title: const Text('Log out'),
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }
}

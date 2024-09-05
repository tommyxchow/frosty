import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/channel.dart';
import 'package:frosty/screens/settings/account/blocked_users.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/widgets/settings_tile_route.dart';

class AccountOptions extends StatelessWidget {
  final AuthStore authStore;

  const AccountOptions({super.key, required this.authStore});

  Future<void> _showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authStore.logout();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Yes'),
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
        SettingsTileRoute(
          leading: const Icon(Icons.person_rounded),
          title: 'My channel',
          useScaffold: false,
          child: VideoChat(
            userId: authStore.user.details!.id,
            userName: authStore.user.details!.displayName,
            userLogin: authStore.user.details!.login,
          ),
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

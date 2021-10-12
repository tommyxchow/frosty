import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authStore = context.read<AuthStore>();

    Future<void> _showDialog() async {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    authStore.logout();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes')),
            ],
          );
        },
      );
    }

    return Observer(
      builder: (_) {
        return Center(
          child: authStore.isLoggedIn
              ? UserAccountsDrawerHeader(
                  currentAccountPicture: InkWell(
                    child: CircleAvatar(
                      foregroundImage: NetworkImage(
                        authStore.user!.profileImageUrl,
                      ),
                    ),
                    onTap: () => _showDialog(),
                  ),
                  accountName: Text(authStore.user!.displayName),
                  accountEmail: Text('Joined on ${DateFormat.yMMMMd('en_US').format(DateTime.parse(authStore.user!.createdAt)).toString()}'),
                )
              : ElevatedButton(
                  onPressed: () => authStore.login(),
                  child: const Text('Login'),
                ),
        );
      },
    );
  }
}

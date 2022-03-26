import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';

class ProfileCard extends StatelessWidget {
  final AuthStore authStore;

  const ProfileCard({Key? key, required this.authStore}) : super(key: key);

  Future<void> _showLoginDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Log In With'),
        children: [
          ColoredBox(
            color: const Color.fromRGBO(145, 70, 255, 0.8),
            child: SimpleDialogOption(
              padding: const EdgeInsets.all(24.0),
              child: const Text(
                'Twitch Account',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                authStore.login();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 20.0),
          const Center(child: Text('Or')),
          SimpleDialogOption(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Token',
              ),
              onSubmitted: (token) {
                authStore.login(customToken: token);
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
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
            },
            child: const Text('Yes'),
            style: TextButton.styleFrom(primary: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Observer(
        builder: (context) {
          if (authStore.error != null) {
            return ListTile(
              title: const Text('Failed to connect'),
              trailing: OutlinedButton(
                onPressed: authStore.init,
                child: const Text('Try Again'),
              ),
            );
          }
          if (authStore.isLoggedIn && authStore.user.details != null) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFFFFFF),
                foregroundImage: CachedNetworkImageProvider(authStore.user.details!.profileImageUrl),
              ),
              title: Text(authStore.user.details!.displayName),
              trailing: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_outlined),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(primary: Colors.red),
              ),
            );
          }
          return ListTile(
            isThreeLine: true,
            leading: const Icon(
              Icons.no_accounts,
              size: 40,
            ),
            title: const Text('Anonymous User'),
            subtitle: const Text('Log in to view your followed streams, send chat messages, and more.'),
            trailing: OutlinedButton(
              onPressed: () => _showLoginDialog(context),
              child: const Text('Log In'),
            ),
          );
        },
      ),
    );
  }
}

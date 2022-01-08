import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:intl/intl.dart';

class ProfileCard extends StatelessWidget {
  final AuthStore authStore;

  const ProfileCard({Key? key, required this.authStore}) : super(key: key);

  Future<void> _showDialog(BuildContext context) {
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
              Navigator.of(context).pop();
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
          if (authStore.isLoggedIn && authStore.user.details != null) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFFFFFF),
                foregroundImage: CachedNetworkImageProvider(authStore.user.details!.profileImageUrl),
              ),
              title: Text(authStore.user.details!.displayName),
              subtitle: Text('Joined on ${DateFormat.yMMMd().format(DateTime.parse(authStore.user.details!.createdAt))}'),
              trailing: OutlinedButton(
                onPressed: () => _showDialog(context),
                child: const Text('Log Out'),
                style: OutlinedButton.styleFrom(primary: Colors.red),
              ),
            );
          }
          return ListTile(
            isThreeLine: true,
            leading: const Icon(
              Icons.account_circle_outlined,
              size: 40,
            ),
            title: const Text('Anonymous User'),
            subtitle: const Text('Log in with to view your followed streams, send chat messages, and more.'),
            trailing: OutlinedButton(
              onPressed: authStore.login,
              child: const Text('Log In'),
            ),
          );
        },
      ),
    );
  }
}

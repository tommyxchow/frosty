import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';

class BlockedUsers extends StatelessWidget {
  final AuthStore authStore;
  const BlockedUsers({
    Key? key,
    required this.authStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> _showDialog(BuildContext context, {required String targetUser, required String targetUserId}) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unblock'),
          content: Text('Are you sure you want to unblock $targetUser?'),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                authStore.user.unblock(targetId: targetUserId, headers: authStore.headersTwitch);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: RefreshIndicator(
        onRefresh: () => authStore.user.refreshBlockedUsers(headers: authStore.headersTwitch),
        child: Observer(
          builder: (context) {
            if (authStore.user.blockedUsers.isEmpty) {
              return const Center(
                child: Text('You don\'t have any blocked users.'),
              );
            }
            return ListView(
              children: authStore.user.blockedUsers
                  .map(
                    (user) => ListTile(
                      title: Text(user.displayName),
                      trailing: OutlinedButton(
                        child: const Text('Unblock'),
                        onPressed: () => _showDialog(context, targetUser: user.displayName, targetUserId: user.userId),
                        style: OutlinedButton.styleFrom(primary: Colors.red),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

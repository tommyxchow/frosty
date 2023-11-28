import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/alert_message.dart';

class BlockedUsers extends StatelessWidget {
  final AuthStore authStore;

  const BlockedUsers({
    super.key,
    required this.authStore,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        HapticFeedback.lightImpact();

        await authStore.user
            .refreshBlockedUsers(headers: authStore.headersTwitch);
      },
      child: Observer(
        builder: (context) {
          if (authStore.user.blockedUsers.isEmpty) {
            return const Center(
              child: AlertMessage(
                message: 'No blocked users',
              ),
            );
          }
          return ListView(
            children: authStore.user.blockedUsers.map(
              (blockedUser) {
                final displayName = getReadableName(
                  blockedUser.displayName,
                  blockedUser.userLogin,
                );

                return ListTile(
                  title: Text(displayName),
                  trailing: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => authStore.showBlockDialog(
                      context,
                      targetUser: displayName,
                      targetUserId: blockedUser.userId,
                    ),
                    child: const Text('Unblock'),
                  ),
                );
              },
            ).toList(),
          );
        },
      ),
    );
  }
}

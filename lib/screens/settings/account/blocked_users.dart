import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/list_tile.dart';

class BlockedUsers extends StatelessWidget {
  final AuthStore authStore;

  const BlockedUsers({
    Key? key,
    required this.authStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
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
                final displayName = regexEnglish
                        .hasMatch(blockedUser.displayName)
                    ? blockedUser.displayName
                    : '${blockedUser.displayName} (${blockedUser.userLogin})';

                return FrostyListTile(
                  title: displayName,
                  trailing: Button(
                    color: Colors.red,
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

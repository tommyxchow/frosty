import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/block_button.dart';

class BlockedUsers extends StatelessWidget {
  final AuthStore authStore;

  const BlockedUsers({
    Key? key,
    required this.authStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();

          await authStore.user.refreshBlockedUsers(headers: authStore.headersTwitch);
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
                (user) {
                  final displayName = regexEnglish.hasMatch(user.displayName) ? user.displayName : '${user.displayName} (${user.userLogin})';

                  return ListTile(
                    title: Tooltip(
                      preferBelow: false,
                      message: displayName,
                      child: Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: BlockButton(
                      authStore: authStore,
                      targetUser: displayName,
                      targetUserId: user.userId,
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ),
    );
  }
}

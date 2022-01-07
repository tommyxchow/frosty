import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';

class BlockButton extends StatelessWidget {
  final AuthStore authStore;
  final String targetUser;
  final String targetUserId;

  const BlockButton({
    Key? key,
    required this.authStore,
    required this.targetUser,
    required this.targetUserId,
  }) : super(key: key);

  Future<void> _showDialog(
    BuildContext context, {
    required bool isBlocked,
    required String targetUser,
    required String targetUserId,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: isBlocked ? const Text('Unblock') : const Text('Block'),
        content: Text('Are you sure you want to ${isBlocked ? 'unblock $targetUser' : 'block $targetUser'}?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (isBlocked) {
                authStore.user.unblock(targetId: targetUserId, headers: authStore.headersTwitch);
              } else {
                authStore.user.block(targetId: targetUserId, headers: authStore.headersTwitch);
              }
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
    return Observer(
      builder: (context) {
        final isBlocked = authStore.user.blockedUsers.where((blockedUser) => blockedUser.userId == targetUserId).isNotEmpty;

        return OutlinedButton(
          child: isBlocked ? const Text('Unblock') : const Text('Block'),
          onPressed: () => _showDialog(
            context,
            isBlocked: isBlocked,
            targetUser: targetUser,
            targetUserId: targetUserId,
          ),
          style: OutlinedButton.styleFrom(primary: Colors.red),
        );
      },
    );
  }
}

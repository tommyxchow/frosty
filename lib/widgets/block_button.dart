import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';

class BlockButton extends StatelessWidget {
  final AuthStore authStore;
  final String targetUser;
  final String targetUserId;
  final bool simple;

  const BlockButton({
    Key? key,
    required this.authStore,
    required this.targetUser,
    required this.targetUserId,
    this.simple = true,
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
        content: Text(
            'Are you sure you want to ${isBlocked ? 'unblock $targetUser?' : 'block $targetUser? This will remove them from channel lists, search results, and chat messages.'}'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
            style: TextButton.styleFrom(primary: Colors.red),
          ),
          ElevatedButton(
            onPressed: () {
              if (isBlocked) {
                authStore.user.unblock(targetId: targetUserId, headers: authStore.headersTwitch);
              } else {
                authStore.user.block(
                  targetId: targetUserId,
                  displayName: targetUser,
                  headers: authStore.headersTwitch,
                );
              }
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
    return Observer(
      builder: (context) {
        final isBlocked = authStore.user.blockedUsers.where((blockedUser) => blockedUser.userId == targetUserId).isNotEmpty;

        return OutlinedButton.icon(
          icon: const Icon(Icons.block),
          label: isBlocked ? Text(simple ? 'Unblock' : 'Unblock $targetUser') : Text(simple ? 'Block' : 'Block $targetUser'),
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

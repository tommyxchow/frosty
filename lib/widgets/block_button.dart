import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';

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
      builder: (context) => FrostyDialog(
        title: isBlocked ? 'Unblock' : 'Block',
        content: Text(
            'Are you sure you want to ${isBlocked ? 'unblock $targetUser?' : 'block $targetUser? This will remove them from channel lists, search results, and chat messages.'}'),
        actions: [
          Button(
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
          Button(
            fill: true,
            onPressed: Navigator.of(context).pop,
            color: Colors.red.shade700,
            child: const Text('Cancel'),
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

        return Button(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          icon: const Icon(Icons.block),
          color: Colors.red.shade700,
          fill: true,
          onPressed: () => _showDialog(
            context,
            isBlocked: isBlocked,
            targetUser: targetUser,
            targetUserId: targetUserId,
          ),
          child: isBlocked ? Text(simple ? 'Unblock' : 'Unblock $targetUser') : Text(simple ? 'Block' : 'Block $targetUser'),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';

class BlockedUsers extends StatefulWidget {
  final AuthStore authStore;

  const BlockedUsers({
    super.key,
    required this.authStore,
  });

  @override
  State<BlockedUsers> createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        HapticFeedback.lightImpact();

        await widget.authStore.user.refreshBlockedUsers();
      },
      child: Observer(
        builder: (context) {
          if (widget.authStore.user.blockedUsers.isEmpty) {
            return const Center(
              child: AlertMessage(
                message: 'No blocked users',
                vertical: true,
              ),
            );
          }
          return Stack(
            children: [
              ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 116),
                children: widget.authStore.user.blockedUsers.map(
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
                        onPressed: () => widget.authStore.showBlockDialog(
                          context,
                          targetUser: displayName,
                          targetUserId: blockedUser.userId,
                        ),
                        child: const Text('Unblock'),
                      ),
                    );
                  },
                ).toList(),
              ),
              Positioned(
                top: 108,
                left: 0,
                right: 0,
                child: AnimatedScrollBorder(
                  scrollController: _scrollController,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

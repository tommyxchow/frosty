import 'package:flutter/material.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';

/// Moderator actions (delete / timeout / ban, plus unban) for [targetUserId],
/// reused by the message long-press menu and the user panel.
///
/// Renders nothing unless the viewer can moderate the channel. [messageId]
/// enables the per-message Delete action; omit it (e.g. the user panel, which
/// isn't tied to one message) to hide Delete. The unban action only appears
/// when the user is currently banned/timed-out (seen via CLEARCHAT).
class ModerationActions extends StatelessWidget {
  final ChatStore chatStore;
  final String targetUserId;

  /// Display name used in confirmation notifications.
  final String targetName;

  /// The message to delete; null hides the Delete action.
  final String? messageId;

  const ModerationActions({
    super.key,
    required this.chatStore,
    required this.targetUserId,
    required this.targetName,
    this.messageId,
  });

  @override
  Widget build(BuildContext context) {
    if (!chatStore.auth.user.canModerate(chatStore.channelId)) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        // Compact one-row punitive actions, ordered least- to most-destructive.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Row(
            children: [
              if (messageId != null) ...[
                Expanded(
                  child: _button(
                    Icons.delete_outline,
                    'Delete',
                    () => _run(context, _delete),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: _button(
                  Icons.timer_outlined,
                  'Timeout 10min',
                  () => _run(context, _timeout),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _button(
                  Icons.block,
                  'Ban',
                  () => _run(context, _ban),
                ),
              ),
            ],
          ),
        ),
        // Recovery action, separate from the punitive row to avoid mistaps and
        // only shown when the user is actually banned/timed-out.
        if (chatStore.isUserBannedOrTimedOut(targetUserId))
          ListTile(
            onTap: () => _run(context, _unban),
            leading: const Icon(Icons.lock_open_rounded),
            title: const Text('Remove ban or timeout'),
          ),
      ],
    );
  }

  /// Compact icon-over-label button.
  Widget _button(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  /// Closes the sheet, then runs [action], surfacing Twitch's reason on failure.
  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    Navigator.pop(context);
    try {
      await action();
    } on ApiException catch (e) {
      chatStore.updateNotification(e.message);
    }
  }

  Future<void> _delete() async {
    final success = await chatStore.auth.user.deleteMessage(
      broadcasterId: chatStore.channelId,
      messageId: messageId!,
    );
    chatStore.updateNotification(
      success ? 'Message deleted' : 'Failed to delete message',
    );
  }

  Future<void> _timeout() async {
    final success = await chatStore.auth.user.banOrTimeoutUser(
      broadcasterId: chatStore.channelId,
      userIdToBan: targetUserId,
      duration: 600, // 10 minutes
    );
    chatStore.updateNotification(
      success ? '$targetName timed out for 10 minutes.' : 'Failed to timeout user',
    );
  }

  Future<void> _ban() async {
    final success = await chatStore.auth.user.banOrTimeoutUser(
      broadcasterId: chatStore.channelId,
      userIdToBan: targetUserId,
    );
    chatStore.updateNotification(
      success ? '$targetName banned.' : 'Failed to ban user',
    );
  }

  Future<void> _unban() async {
    final success = await chatStore.auth.user.unbanUser(
      broadcasterId: chatStore.channelId,
      userIdToUnban: targetUserId,
    );
    if (success) chatStore.clearUserBanState(targetUserId);
    chatStore.updateNotification(
      success
          ? 'Removed ban/timeout for $targetName.'
          : 'Failed to remove ban or timeout',
    );
  }
}

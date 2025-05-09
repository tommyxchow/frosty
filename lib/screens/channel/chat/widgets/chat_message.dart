import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_user_modal.dart';
import 'package:frosty/screens/channel/chat/widgets/reply_thread.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:provider/provider.dart';

class ChatMessage extends StatelessWidget {
  final IRCMessage ircMessage;
  final ChatStore chatStore;
  final bool isModal;
  final bool showReplyHeader;

  const ChatMessage({
    super.key,
    required this.ircMessage,
    required this.chatStore,
    this.isModal = false,
    this.showReplyHeader = true,
  });

  void onTapName(BuildContext context) {
    // Ignore if the message is a recent message in the modal bottom sheet.
    if (isModal) return;

    // Ignore if long-pressing own username.
    if (ircMessage.user == null ||
        ircMessage.user == chatStore.auth.user.details?.login) {
      return;
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => ChatUserModal(
        chatStore: chatStore,
        username: ircMessage.user!,
        userId: ircMessage.tags['user-id']!,
        displayName: ircMessage.tags['display-name']!,
      ),
    );
  }

  void onTapPingedUser(
    BuildContext context, {
    required String nickname,
  }) {
    // Ignore if the message is a recent message in the modal bottom sheet.
    if (isModal) return;

    final twitchApi = context.read<TwitchApi>();
    final authStore = context.read<AuthStore>();
    twitchApi
        .getUser(
      headers: authStore.headersTwitch,
      userLogin: nickname,
    )
        .then((user) {
      if (context.mounted) {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => ChatUserModal(
            chatStore: chatStore,
            username: user.login,
            userId: user.id,
            displayName: user.displayName,
          ),
        );
      }
    });
  }

  void onLongPressMessage(BuildContext context, TextStyle defaultTextStyle) {
    HapticFeedback.lightImpact();

    if (ircMessage.command != Command.privateMessage &&
        ircMessage.command != Command.userState) {
      copyMessage();
      return;
    }

    final authStore = context.read<AuthStore>();
    final userStore = authStore.user;
    final isModerator = userStore.isModerator(chatStore.channelId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        primary: false,
        children: [
          ListTile(
            title: Text.rich(
              TextSpan(
                children: ircMessage.generateSpan(
                  context,
                  assetsStore: chatStore.assetsStore,
                  emoteScale: chatStore.settings.emoteScale,
                  badgeScale: chatStore.settings.badgeScale,
                  useReadableColors: chatStore.settings.useReadableColors,
                  launchExternal: chatStore.settings.launchUrlExternal,
                  timestamp: chatStore.settings.timestampType,
                  channelIdToUserTwitch:
                      chatStore.assetsStore.channelIdToUserTwitch,
                ),
                style: defaultTextStyle,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              copyMessage();
              Navigator.pop(context);
            },
            leading: const Icon(Icons.copy),
            title: const Text('Copy message'),
          ),
          ListTile(
            onTap: () {
              chatStore.replyingToMessage = ircMessage;
              chatStore.textFieldFocusNode.requestFocus();
              Navigator.pop(context);
            },
            leading: const Icon(Icons.reply),
            title: const Text('Reply to message'),
          ),
          if (isModerator && ircMessage.tags['user-id'] != null && ircMessage.tags['id'] != null) ...[
            const Divider(),
            ListTile(
              onTap: () {
                deleteMessageAction(context);
                Navigator.pop(context);
              },
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete message'),
            ),
            ListTile(
              onTap: () {
                timeoutUserAction(context);
                Navigator.pop(context);
              },
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Timeout for 10min'),
            ),
            ListTile(
              onTap: () {
                banUserAction(context);
                Navigator.pop(context);
              },
              leading: const Icon(Icons.block),
              title: const Text('Ban user'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> copyMessage() async {
    await Clipboard.setData(ClipboardData(text: ircMessage.message ?? ''));

    chatStore.updateNotification('Message copied');
  }

  Future<void> deleteMessageAction(BuildContext context) async {
    final authStore = context.read<AuthStore>();
    final userStore = authStore.user;
    final success = await userStore.deleteMessage(
      broadcasterId: chatStore.channelId,
      messageId: ircMessage.tags['id']!,
      headers: authStore.headersTwitch,
    );
    if (success) {
      chatStore.updateNotification('Message deleted');
    } else {
      chatStore.updateNotification('Failed to delete message');
    }
  }

  Future<void> timeoutUserAction(BuildContext context) async {
    final authStore = context.read<AuthStore>();
    final userStore = authStore.user;
    final success = await userStore.banOrTimeoutUser(
      broadcasterId: chatStore.channelId,
      userIdToBan: ircMessage.tags['user-id']!,
      headers: authStore.headersTwitch,
      duration: 600, // 10 minutes
    );
    if (success) {
      chatStore.updateNotification(
        'User ${ircMessage.tags['display-name'] ?? ircMessage.user} timed out for 10 minutes.',
      );
    } else {
      chatStore.updateNotification('Failed to timeout user');
    }
  }

  Future<void> banUserAction(BuildContext context) async {
    final authStore = context.read<AuthStore>();
    final userStore = authStore.user;
    final success = await userStore.banOrTimeoutUser(
      broadcasterId: chatStore.channelId,
      userIdToBan: ircMessage.tags['user-id']!,
      headers: authStore.headersTwitch,
    );
    if (success) {
      chatStore.updateNotification(
        'User ${ircMessage.tags['display-name'] ?? ircMessage.user} banned.',
      );
    } else {
      chatStore.updateNotification('Failed to ban user');
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final messageHeaderIconSize =
        defaultBadgeSize * chatStore.settings.badgeScale;
    final messageHeaderTextColor =
        defaultTextStyle.color?.withValues(alpha: 0.5);
    const messageHeaderFontWeight = FontWeight.w600;

    return Observer(
      builder: (context) {
        Color? highlightColor;
        final Widget renderMessage;

        switch (ircMessage.command) {
          case Command.privateMessage:
          case Command.userState:
            final shouldHighlightFirstMessage =
                chatStore.settings.highlightFirstTimeChatter &&
                    ircMessage.tags['first-msg'] == '1';
            final shouldHighlightMessage = chatStore.settings.showUserNotices &&
                ircMessage.tags['msg-id'] == 'highlighted-message';

            final messageSpan = Text.rich(
              TextSpan(
                children: ircMessage.generateSpan(
                  context,
                  onTapName: () => onTapName(context),
                  onTapPingedUser: (nickname) =>
                      onTapPingedUser(context, nickname: nickname),
                  style: defaultTextStyle,
                  assetsStore: chatStore.assetsStore,
                  emoteScale: chatStore.settings.emoteScale,
                  badgeScale: chatStore.settings.badgeScale,
                  useReadableColors: chatStore.settings.useReadableColors,
                  launchExternal: chatStore.settings.launchUrlExternal,
                  timestamp: chatStore.settings.timestampType,
                  channelIdToUserTwitch:
                      chatStore.assetsStore.channelIdToUserTwitch,
                ),
              ),
            );

            // Check if the message is replying to another message.
            final replyUser = ircMessage.tags['reply-parent-display-name'];
            final replyBody = ircMessage.tags['reply-parent-msg-body'];

            Widget? messageHeaderIcon;
            Widget? messageHeader;
            if (replyUser != null && replyBody != null && showReplyHeader) {
              messageHeaderIcon = Icon(
                Icons.chat_rounded,
                size: messageHeaderIconSize,
                color: messageHeaderTextColor,
              );
              messageHeader = GestureDetector(
                onTap: isModal
                    ? null
                    : () => showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ReplyThread(
                              selectedMessage: ircMessage,
                              chatStore: chatStore,
                            );
                          },
                        ),
                child: Text(
                  'Replying to @$replyUser: $replyBody',
                  maxLines: 1,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: messageHeaderTextColor,
                  ),
                ),
              );
            } else if (shouldHighlightFirstMessage) {
              highlightColor = Colors.purple;
              messageHeaderIcon = Icon(
                Icons.auto_awesome_rounded,
                size: messageHeaderIconSize,
                color: messageHeaderTextColor,
              );
              messageHeader = Text(
                'First message',
                style: TextStyle(
                  fontWeight: messageHeaderFontWeight,
                  color: messageHeaderTextColor,
                ),
              );
            } else if (shouldHighlightMessage) {
              highlightColor = const Color(0xff9146ff);
              messageHeader = Text(
                'Highlighted message',
                style: TextStyle(
                  fontWeight: messageHeaderFontWeight,
                  color: messageHeaderTextColor,
                ),
              );
            }

            // If user is being mentioned in the message, highlight it red.
            if (ircMessage.mention == true) highlightColor = Colors.red;

            if (messageHeader != null) {
              renderMessage = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (messageHeaderIcon != null)
                    Row(
                      children: [
                        messageHeaderIcon,
                        const SizedBox(width: 4),
                        Flexible(
                          child: messageHeader,
                        ),
                      ],
                    )
                  else
                    messageHeader,
                  const SizedBox(height: 4),
                  messageSpan,
                ],
              );
            } else {
              renderMessage = messageSpan;
            }

            break;
          case Command.clearChat:
          case Command.clearMessage:
            // Render timeouts and bans
            final banDuration = ircMessage.tags['ban-duration'];

            renderMessage = Opacity(
              opacity: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (banDuration == null)
                    if (ircMessage.command == Command.clearMessage)
                      const Text(
                        'Message deleted',
                        style: TextStyle(fontWeight: messageHeaderFontWeight),
                      )
                    else
                      const Text(
                        'Permanently banned',
                        style: TextStyle(fontWeight: messageHeaderFontWeight),
                      )
                  else
                    Text(
                      'Timed out for $banDuration ${int.parse(banDuration) > 1 ? 'seconds' : 'second'}',
                      style:
                          const TextStyle(fontWeight: messageHeaderFontWeight),
                    ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: ircMessage.generateSpan(
                        context,
                        onTapName: () => onTapName(context),
                        style: defaultTextStyle,
                        assetsStore: chatStore.assetsStore,
                        emoteScale: chatStore.settings.emoteScale,
                        badgeScale: chatStore.settings.badgeScale,
                        showMessage: chatStore.settings.showDeletedMessages,
                        useReadableColors: chatStore.settings.useReadableColors,
                        launchExternal: chatStore.settings.launchUrlExternal,
                        timestamp: chatStore.settings.timestampType,
                        channelIdToUserTwitch:
                            chatStore.assetsStore.channelIdToUserTwitch,
                      ),
                    ),
                  ),
                ],
              ),
            );
            break;
          case Command.notice:
            renderMessage = Text.rich(
              TextSpan(text: ircMessage.message),
              style: TextStyle(color: messageHeaderTextColor),
            );
            break;
          case Command.userNotice:
            if (chatStore.settings.showUserNotices) {
              highlightColor = const Color(0xff9146ff);
              Widget? messageHeaderIcon;
              Widget? messageHeader;

              if (ircMessage.tags.containsKey('system-msg')) {
                final messageId = ircMessage.tags['msg-id'];
                final isGift = messageId?.contains('gift') == true;
                final isSub = messageId?.contains('sub') == true;
                final isRaid = messageId?.contains('raid') == true;
                // TODO: Implement Prime sub icons when a crown icon is added.
                // final isPrime = ircMessage.tags['msg-param-sub-plan'] == 'Prime';

                IconData? icon;
                if (isGift) {
                  icon = Icons.card_giftcard_rounded;
                } else if (isSub) {
                  icon = Icons.star_rounded;
                } else if (isRaid) {
                  icon = Icons.people_rounded;
                }

                if (icon != null) {
                  messageHeaderIcon = Icon(
                    icon,
                    size: messageHeaderIconSize,
                    color: messageHeaderTextColor,
                  );
                }

                messageHeader = Text(
                  ircMessage.tags['system-msg']!,
                  style: TextStyle(
                    fontWeight: messageHeaderFontWeight,
                    color: messageHeaderTextColor,
                  ),
                );
              } else if (ircMessage.tags['msg-id'] == 'announcement') {
                messageHeaderIcon = Icon(
                  Icons.campaign_rounded,
                  size: messageHeaderIconSize,
                );
                messageHeader = const Text(
                  'Announcement',
                  style: TextStyle(fontWeight: messageHeaderFontWeight),
                );
              }

              renderMessage = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (messageHeader != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (messageHeaderIcon != null) ...[
                          messageHeaderIcon,
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: messageHeader,
                        ),
                      ],
                    ),
                  if (ircMessage.message != null) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: ircMessage.generateSpan(
                          context,
                          onTapName: () => onTapName(context),
                          style: defaultTextStyle,
                          assetsStore: chatStore.assetsStore,
                          emoteScale: chatStore.settings.emoteScale,
                          badgeScale: chatStore.settings.badgeScale,
                          useReadableColors:
                              chatStore.settings.useReadableColors,
                          launchExternal: chatStore.settings.launchUrlExternal,
                          timestamp: chatStore.settings.timestampType,
                          channelIdToUserTwitch:
                              chatStore.assetsStore.channelIdToUserTwitch,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            } else {
              renderMessage = const SizedBox();
            }
            break;
          default:
            renderMessage = const SizedBox();
        }

        final paddedMessage = Padding(
          padding: EdgeInsets.symmetric(
            vertical: chatStore.settings.messageSpacing / 2,
            horizontal: highlightColor == null ? 12 : 0,
          ),
          child: renderMessage,
        );

        // Add a divider above the message if dividers are enabled.
        final dividedMessage = chatStore.settings.showChatMessageDividers
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  paddedMessage,
                  const Divider(),
                ],
              )
            : paddedMessage;

        // Color the message if the color has been set.
        final coloredMessage = highlightColor == null
            ? dividedMessage
            : Container(
                padding: const EdgeInsets.only(left: 8, right: 12),
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.1),
                  border: Border(
                    left: BorderSide(color: highlightColor, width: 4),
                  ),
                ),
                child: dividedMessage,
              );

        return GestureDetector(
          // If a new message comes in while long pressing, prevent scolling
          // so that the long press doesn't miss and activate on the wrong message.
          onLongPressStart: (_) {
            chatStore.pauseAutoScrollForInteraction();
          },
          onLongPressEnd: (_) {
            chatStore.resumeAutoScrollAfterInteraction();
            onLongPressMessage(context, defaultTextStyle);
          },
          onLongPressCancel: () {
            chatStore.resumeAutoScrollAfterInteraction();
          },
          // Use an InkWell here to get the ripple effect on tap
          child: InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              if (chatStore.assetsStore.showEmoteMenu) {
                chatStore.assetsStore.showEmoteMenu = false;
              }
            },
            child: coloredMessage,
          ),
        );
      },
    );
  }
}

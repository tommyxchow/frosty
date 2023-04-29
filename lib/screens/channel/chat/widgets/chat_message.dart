import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_user_modal.dart';

class ChatMessage extends StatelessWidget {
  final IRCMessage ircMessage;
  final ChatStore chatStore;
  final bool isModal;

  const ChatMessage({
    Key? key,
    required this.ircMessage,
    required this.chatStore,
    this.isModal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void onTapName() {
      // Ignore if the message is a recent message in the modal bottom sheet.
      if (isModal) return;

      // Ignore if long-pressing own username.
      if (ircMessage.user == null ||
          ircMessage.user == chatStore.auth.user.details?.login) return;

      showModalBottomSheet(
        backgroundColor: Colors.transparent,
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

    Future<void> onLongPressMessage() async {
      HapticFeedback.lightImpact();

      await Clipboard.setData(ClipboardData(text: ircMessage.message));

      chatStore.updateNotification('Message copied');
    }

    final defaultTextStyle = DefaultTextStyle.of(context).style;

    return Observer(
      builder: (context) {
        Color? color;
        final Widget renderMessage;

        switch (ircMessage.command) {
          case Command.privateMessage:
          case Command.userState:
            // If user is being mentioned in the message, highlight it red.
            if (ircMessage.mention == true) color = Colors.red.withOpacity(0.2);
            if (chatStore.settings.highlightFirstTimeChatter &&
                ircMessage.tags['first-msg'] == '1') {
              color = Colors.green.withOpacity(0.2);
            }

            final messageSpan = Text.rich(
              TextSpan(
                children: ircMessage.generateSpan(
                  onTapName: onTapName,
                  style: defaultTextStyle,
                  assetsStore: chatStore.assetsStore,
                  emoteScale: chatStore.settings.emoteScale,
                  badgeScale: chatStore.settings.badgeScale,
                  useReadableColors: chatStore.settings.useReadableColors,
                  isLightTheme:
                      Theme.of(context).brightness == Brightness.light,
                  launchExternal: chatStore.settings.launchUrlExternal,
                  timestamp: chatStore.settings.timestampType,
                ),
              ),
            );

            // Check if the message is replying to another message.
            final replyUser = ircMessage.tags['reply-parent-display-name'];
            final replyBody = ircMessage.tags['reply-parent-msg-body'];

            if ((replyUser != null && replyBody != null) ||
                (chatStore.settings.highlightFirstTimeChatter &&
                    ircMessage.tags['first-msg'] == '1')) {
              renderMessage = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        replyUser != null && replyBody != null
                            ? Icons.reply_rounded
                            : Icons.new_releases_outlined,
                        size: defaultBadgeSize * chatStore.settings.badgeScale,
                        color: defaultTextStyle.color?.withOpacity(0.5),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: 5.0),
                      Flexible(
                        child: replyUser != null && replyBody != null
                            ? Tooltip(
                                message: 'Replying to @$replyUser: $replyBody',
                                preferBelow: false,
                                triggerMode: TooltipTriggerMode.tap,
                                showDuration: const Duration(seconds: 5),
                                child: Text(
                                  'Replying to @$replyUser: $replyBody',
                                  maxLines: 1,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: defaultTextStyle.color
                                        ?.withOpacity(0.5),
                                  ),
                                ),
                              )
                            : Text(
                                'First time chatting',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      defaultTextStyle.color?.withOpacity(0.5),
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
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
              opacity: 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (banDuration == null)
                    if (ircMessage.command == Command.clearMessage)
                      const Text(
                        'Message deleted',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    else
                      const Text(
                        'Permanently banned',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                  else
                    Text(
                      'Timed out for $banDuration ${int.parse(banDuration) > 1 ? 'seconds' : 'second'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: 5.0),
                  Text.rich(
                    TextSpan(
                      children: ircMessage.generateSpan(
                        onTapName: onTapName,
                        style: defaultTextStyle,
                        assetsStore: chatStore.assetsStore,
                        emoteScale: chatStore.settings.emoteScale,
                        badgeScale: chatStore.settings.badgeScale,
                        showMessage: chatStore.settings.showDeletedMessages,
                        useReadableColors: chatStore.settings.useReadableColors,
                        isLightTheme:
                            Theme.of(context).brightness == Brightness.light,
                        launchExternal: chatStore.settings.launchUrlExternal,
                        timestamp: chatStore.settings.timestampType,
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
              style: TextStyle(color: defaultTextStyle.color?.withOpacity(0.5)),
            );
            break;
          case Command.userNotice:
            if (chatStore.settings.showUserNotices) {
              color = Colors.deepPurple.withOpacity(0.2);

              renderMessage = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ircMessage.tags.containsKey('system-msg'))
                    Text(
                      ircMessage.tags['system-msg']!,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: defaultTextStyle.color?.withOpacity(0.5)),
                    ),
                  if (ircMessage.tags['msg-id'] == 'announcement')
                    Row(
                      children: [
                        Icon(
                          Icons.announcement_outlined,
                          size:
                              defaultBadgeSize * chatStore.settings.badgeScale,
                        ),
                        const SizedBox(width: 5.0),
                        const Text(
                          'Announcement',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  const SizedBox(height: 5.0),
                  if (ircMessage.message != null)
                    Text.rich(
                      TextSpan(
                        children: ircMessage.generateSpan(
                          onTapName: onTapName,
                          style: defaultTextStyle,
                          assetsStore: chatStore.assetsStore,
                          emoteScale: chatStore.settings.emoteScale,
                          badgeScale: chatStore.settings.badgeScale,
                          useReadableColors:
                              chatStore.settings.useReadableColors,
                          isLightTheme:
                              Theme.of(context).brightness == Brightness.light,
                          launchExternal: chatStore.settings.launchUrlExternal,
                          timestamp: chatStore.settings.timestampType,
                        ),
                      ),
                    ),
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
              horizontal: 10.0),
          child: renderMessage,
        );

        // Add a divider above the message if dividers are enabled.
        final dividedMessage = chatStore.settings.showChatMessageDividers
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  paddedMessage,
                  const Divider(
                    height: 1.0,
                    thickness: 1.0,
                  ),
                ],
              )
            : paddedMessage;

        // Color the message if the color has been set.
        final coloredMessage = color == null
            ? dividedMessage
            : ColoredBox(color: color, child: dividedMessage);

        return InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (chatStore.assetsStore.showEmoteMenu) {
              chatStore.assetsStore.showEmoteMenu = false;
            }
          },
          onLongPress: onLongPressMessage,
          child: coloredMessage,
        );
      },
    );
  }
}

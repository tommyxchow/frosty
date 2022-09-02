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
    void onLongPressName() {
      // Ignore if the message is a recent message in the modal bottom sheet.
      if (isModal) return;

      // Ignore if long-pressing own username.
      if (ircMessage.user == null || ircMessage.user == chatStore.auth.user.details?.login) return;

      HapticFeedback.lightImpact();

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

    return Observer(
      builder: (context) {
        Color? color;
        final Widget renderMessage;

        switch (ircMessage.command) {
          case Command.privateMessage:
          case Command.userState:
            // If user is being mentioned in the message, highlight it red.
            if (ircMessage.mention == true) color = Colors.red.withOpacity(0.3);

            final messageSpan = Text.rich(
              TextSpan(
                children: ircMessage.generateSpan(
                  onLongPressName: onLongPressName,
                  style: DefaultTextStyle.of(context).style,
                  assetsStore: chatStore.assetsStore,
                  emoteScale: chatStore.settings.emoteScale,
                  badgeScale: chatStore.settings.badgeScale,
                  useZeroWidth: chatStore.settings.showZeroWidth,
                  useReadableColors: chatStore.settings.useReadableColors,
                  isLightTheme: Theme.of(context).brightness == Brightness.light,
                  launchExternal: chatStore.settings.launchUrlExternal,
                  timestamp: chatStore.settings.timestampType,
                ),
              ),
            );

            // Check if the message is replying to another message.
            final replyUser = ircMessage.tags['reply-parent-display-name'];
            final replyBody = ircMessage.tags['reply-parent-msg-body'];

            if (replyUser != null && replyBody != null) {
              renderMessage = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: defaultBadgeSize * chatStore.settings.badgeScale,
                        ),
                        const SizedBox(width: 5.0),
                        Flexible(
                          child: Tooltip(
                            message: 'Replying to @$replyUser: $replyBody',
                            preferBelow: false,
                            child: Text(
                              'Replying to @$replyUser: $replyBody',
                              maxLines: 1,
                              style: const TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ),
                      ],
                    ),
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
              opacity: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: ircMessage.generateSpan(
                        onLongPressName: onLongPressName,
                        style: DefaultTextStyle.of(context).style,
                        assetsStore: chatStore.assetsStore,
                        emoteScale: chatStore.settings.emoteScale,
                        badgeScale: chatStore.settings.badgeScale,
                        showMessage: chatStore.settings.showDeletedMessages,
                        useZeroWidth: chatStore.settings.showZeroWidth,
                        useReadableColors: chatStore.settings.useReadableColors,
                        isLightTheme: Theme.of(context).brightness == Brightness.light,
                        launchExternal: chatStore.settings.launchUrlExternal,
                        timestamp: chatStore.settings.timestampType,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  if (banDuration == null)
                    if (ircMessage.command == Command.clearMessage)
                      const Text(
                        'Message deleted',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    else
                      const Text(
                        'User permanently banned',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                  else
                    Text(
                      'Timed out for $banDuration ${int.parse(banDuration) > 1 ? 'seconds' : 'second'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                ],
              ),
            );
            break;
          case Command.notice:
            renderMessage = Text.rich(
              TextSpan(text: ircMessage.message),
              style: TextStyle(color: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.5)),
            );
            break;
          case Command.userNotice:
            color = Colors.deepPurple.withOpacity(0.3);

            renderMessage = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ircMessage.tags.containsKey('system-msg'))
                  Text(
                    ircMessage.tags['system-msg']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                if (ircMessage.tags.containsKey('msg-id') && ircMessage.tags['msg-id'] == 'announcement')
                  Row(
                    children: const [
                      Icon(Icons.announcement),
                      SizedBox(width: 5.0),
                      Text(
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
                        onLongPressName: onLongPressName,
                        style: DefaultTextStyle.of(context).style,
                        assetsStore: chatStore.assetsStore,
                        emoteScale: chatStore.settings.emoteScale,
                        badgeScale: chatStore.settings.badgeScale,
                        useZeroWidth: chatStore.settings.showZeroWidth,
                        useReadableColors: chatStore.settings.useReadableColors,
                        isLightTheme: Theme.of(context).brightness == Brightness.light,
                        launchExternal: chatStore.settings.launchUrlExternal,
                        timestamp: chatStore.settings.timestampType,
                      ),
                    ),
                  ),
              ],
            );
            break;
          default:
            renderMessage = const SizedBox();
        }

        final paddedMessage = Padding(
          padding: EdgeInsets.symmetric(vertical: chatStore.settings.messageSpacing / 2, horizontal: 10.0),
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
        final coloredMessage = color == null ? dividedMessage : ColoredBox(color: color, child: dividedMessage);

        return InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (chatStore.assetsStore.showEmoteMenu) chatStore.assetsStore.showEmoteMenu = false;
          },
          onLongPress: onLongPressMessage,
          child: coloredMessage,
        );
      },
    );
  }
}

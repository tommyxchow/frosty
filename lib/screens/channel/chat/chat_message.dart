import 'package:flutter/material.dart';
import 'package:frosty/api/irc_api.dart';
import 'package:frosty/models/irc_message.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';

class ChatMessage extends StatelessWidget {
  final IRCMessage ircMessage;
  final ChatStore chatStore;
  final bool hideMessageIfBanned;
  final bool zeroWidth;

  const ChatMessage({
    Key? key,
    required this.ircMessage,
    required this.chatStore,
    this.hideMessageIfBanned = true,
    this.zeroWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (ircMessage.command) {
      case Command.privateMessage:
      case Command.userState:
        // Render normal chat message (PRIVMSG).
        return Text.rich(
          TextSpan(
            children: ircMessage.generateSpan(
              emoteToObject: chatStore.emoteToObject,
              badgeToObject: chatStore.badgesToObject,
              zeroWidthEnabled: zeroWidth,
            ),
          ),
        );
      case Command.clearChat:
      case Command.clearMessage:
        // Render timeouts and bans
        final banDuration = ircMessage.tags['ban-duration'];
        return Opacity(
          opacity: 0.50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: ircMessage.generateSpan(
                    emoteToObject: chatStore.emoteToObject,
                    badgeToObject: chatStore.badgesToObject,
                    hideMessage: hideMessageIfBanned,
                    zeroWidthEnabled: zeroWidth,
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              if (banDuration == null)
                if (ircMessage.command == Command.clearMessage)
                  const Text('Message Deleted', style: TextStyle(fontWeight: FontWeight.bold))
                else
                  const Text('User Permanently Banned', style: TextStyle(fontWeight: FontWeight.bold))
              else
                Text(
                  int.parse(banDuration) > 1 ? 'Timed out for $banDuration seconds' : 'Timed out for $banDuration second',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
            ],
          ),
        );
      case Command.notice:
        return Text.rich(
          TextSpan(
            text: ircMessage.message,
          ),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.5),
          ),
        );
      case Command.userNotice:
        return ColoredBox(
          color: const Color(0xFF673AB7).withOpacity(0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ircMessage.tags['system-msg']!),
              const SizedBox(height: 5.0),
              if (ircMessage.message != null)
                Text.rich(
                  TextSpan(
                    children: ircMessage.generateSpan(
                      emoteToObject: chatStore.emoteToObject,
                      badgeToObject: chatStore.badgesToObject,
                      zeroWidthEnabled: zeroWidth,
                    ),
                  ),
                ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }
}

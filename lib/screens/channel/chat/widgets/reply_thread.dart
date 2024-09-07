import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/section_header.dart';

class ReplyThread extends StatelessWidget {
  final IRCMessage selectedMessage;
  final ChatStore chatStore;

  const ReplyThread({
    super.key,
    required this.selectedMessage,
    required this.chatStore,
  });

  @override
  Widget build(BuildContext context) {
    final replyParent = chatStore.messages.firstWhereOrNull(
      (message) =>
          message.tags['id'] == selectedMessage.tags['reply-parent-msg-id'],
    );

    final replyDisplayName = selectedMessage.tags['reply-parent-display-name'];
    final replyUserLogin = selectedMessage.tags['reply-parent-user-login'];
    final replyBody = selectedMessage.tags['reply-parent-msg-body'];

    final replyName = replyUserLogin != null
        ? getReadableName(replyDisplayName!, replyUserLogin)
        : replyDisplayName;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Observer(
        builder: (context) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(chatStore.settings.messageScale),
            ),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontSize: chatStore.settings.fontSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SectionHeader(
                    'Replies',
                    isFirst: true,
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                  ),
                  if (replyParent != null)
                    ChatMessage(
                      ircMessage: replyParent,
                      chatStore: chatStore,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Text(
                        '$replyName: $replyBody',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Divider(),
                  Flexible(
                    child: ListView(
                      primary: false,
                      children: chatStore.messages
                          .where(
                            (message) =>
                                message.tags['reply-parent-msg-id'] ==
                                selectedMessage.tags['reply-parent-msg-id'],
                          )
                          .map(
                            (message) => ChatMessage(
                              isModal: true,
                              showReplyHeader: false,
                              ircMessage: message,
                              chatStore: chatStore,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/user_actions_modal.dart';

class ChatUserModal extends StatefulWidget {
  final ChatStore chatStore;
  final String username;
  final String displayName;
  final String userId;

  const ChatUserModal({
    super.key,
    required this.chatStore,
    required this.username,
    required this.displayName,
    required this.userId,
  });

  @override
  State<ChatUserModal> createState() => _ChatUserModalState();
}

class _ChatUserModalState extends State<ChatUserModal> {
  @override
  Widget build(BuildContext context) {
    final name = getReadableName(widget.displayName, widget.username);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ProfilePicture(
              userLogin: widget.username,
            ),
            title: Row(
              children: [
                Flexible(
                  child: Tooltip(
                    message: name,
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.chatStore.auth.isLoggedIn)
                  IconButton(
                    tooltip: 'Reply',
                    onPressed: () {
                      widget.chatStore.textController.text =
                          '@${widget.username} ';
                      Navigator.pop(context);
                      widget.chatStore.textFieldFocusNode.requestFocus();
                    },
                    icon: const Icon(Icons.reply_rounded),
                  ),
                IconButton(
                  tooltip: 'More',
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => UserActionsModal(
                      authStore: widget.chatStore.auth,
                      name: name,
                      userLogin: widget.username,
                      userId: widget.userId,
                    ),
                  ),
                  icon: Icon(Icons.adaptive.more_rounded),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Observer(
              builder: (context) {
                final userMessages = widget.chatStore.messages.reversed
                    .where((message) => message.user == widget.username)
                    .toList();

                if (userMessages.isEmpty) {
                  return const AlertMessage(message: 'No recent messages');
                }

                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      widget.chatStore.settings.messageScale,
                    ),
                  ),
                  child: DefaultTextStyle(
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontSize: widget.chatStore.settings.fontSize),
                    child: ListView.builder(
                      reverse: true,
                      primary: false,
                      itemCount: userMessages.length,
                      itemBuilder: (context, index) => ChatMessage(
                        ircMessage: userMessages[index],
                        chatStore: widget.chatStore,
                        isModal: true,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/widgets/block_report_modal.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/modal.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/section_header.dart';

class ChatUserModal extends StatefulWidget {
  final ChatStore chatStore;
  final String username;
  final String displayName;
  final String userId;

  const ChatUserModal({
    Key? key,
    required this.chatStore,
    required this.username,
    required this.displayName,
    required this.userId,
  }) : super(key: key);

  @override
  State<ChatUserModal> createState() => _ChatUserModalState();
}

class _ChatUserModalState extends State<ChatUserModal> {
  @override
  Widget build(BuildContext context) {
    final userMessages = widget.chatStore.messages.reversed.where((message) => message.user == widget.username).toList();

    return FrostyModal(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(10.0),
              leading: ProfilePicture(
                userLogin: widget.username,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      preferBelow: false,
                      message: widget.displayName,
                      child: Text(
                        widget.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              trailing: widget.chatStore.auth.isLoggedIn
                  ? Button(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      onPressed: () {
                        widget.chatStore.textController.text = '@${widget.username} ';
                        Navigator.pop(context);
                        widget.chatStore.textFieldFocusNode.requestFocus();
                      },
                      child: const Text('Reply'),
                    )
                  : null,
              onTap: () => showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) => BlockReportModal(
                  authStore: widget.chatStore.auth,
                  name: widget.displayName,
                  userLogin: widget.username,
                  userId: widget.userId,
                ),
              ),
            ),
            const SectionHeader(
              'Recent Messages',
              padding: EdgeInsets.all(10.0),
            ),
            Expanded(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: widget.chatStore.settings.messageScale),
                child: DefaultTextStyle(
                  style: DefaultTextStyle.of(context).style.copyWith(fontSize: widget.chatStore.settings.fontSize),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(0.0),
                    reverse: true,
                    itemBuilder: (context, index) => InkWell(
                      onLongPress: () async {
                        await Clipboard.setData(ClipboardData(text: userMessages[index].message));

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message copied!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: ChatMessage(
                        ircMessage: userMessages[index],
                        assetsStore: widget.chatStore.assetsStore,
                        settingsStore: widget.chatStore.settings,
                      ),
                    ),
                    separatorBuilder: (context, index) => widget.chatStore.settings.showChatMessageDividers
                        ? Divider(
                            height: widget.chatStore.settings.messageSpacing,
                            thickness: 1.0,
                          )
                        : SizedBox(height: widget.chatStore.settings.messageSpacing),
                    itemCount: userMessages.length,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

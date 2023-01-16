import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/block_report_modal.dart';
import 'package:frosty/widgets/bottom_sheet.dart';
import 'package:frosty/widgets/button.dart';
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
    final name =
        regexEnglish.hasMatch(widget.displayName) ? widget.displayName : '${widget.displayName} (${widget.username})';

    return FrostyBottomSheet(
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
              onTap: () {
                HapticFeedback.mediumImpact();

                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => BlockReportModal(
                    authStore: widget.chatStore.auth,
                    name: name,
                    userLogin: widget.username,
                    userId: widget.userId,
                  ),
                );
              },
            ),
            const SectionHeader(
              'Recent Messages',
              padding: EdgeInsets.all(10.0),
            ),
            Expanded(
              child: Observer(
                builder: (context) {
                  final userMessages =
                      widget.chatStore.messages.reversed.where((message) => message.user == widget.username).toList();

                  if (userMessages.isEmpty) {
                    return const AlertMessage(message: 'No recent messages');
                  }

                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: widget.chatStore.settings.messageScale),
                    child: DefaultTextStyle(
                      style: DefaultTextStyle.of(context).style.copyWith(fontSize: widget.chatStore.settings.fontSize),
                      child: ListView.builder(
                        reverse: true,
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
            )
          ],
        ),
      ),
    );
  }
}

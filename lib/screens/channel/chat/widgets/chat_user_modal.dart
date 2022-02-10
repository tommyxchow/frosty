import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/widgets/block_report_modal.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/section_header.dart';

class ChatUserModal extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final userMessages = chatStore.messages.reversed.where((message) => message.user == username).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListTile(
                leading: ProfilePicture(
                  userLogin: username,
                ),
                title: Row(
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      tooltip: 'Block or Report User',
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => BlockReportModal(
                          authStore: chatStore.auth,
                          name: displayName,
                          userLogin: username,
                          userId: userId,
                        ),
                      ),
                      icon: Icon(Icons.adaptive.more),
                    ),
                  ],
                ),
                trailing: chatStore.auth.isLoggedIn
                    ? OutlinedButton(
                        onPressed: () {
                          chatStore.textController.text = '@$username ';
                          Navigator.pop(context);
                          chatStore.textFieldFocusNode.requestFocus();
                        },
                        child: const Text('Reply'),
                      )
                    : null,
              ),
            ),
            const SectionHeader(
              'Recent Messages',
              padding: EdgeInsets.all(10.0),
            ),
            Expanded(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: chatStore.settings.messageScale),
                child: ListView.separated(
                  reverse: true,
                  itemBuilder: (context, index) => InkWell(
                    onLongPress: () async {
                      await Clipboard.setData(ClipboardData(text: userMessages[index].message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message copied!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: ChatMessage(
                      ircMessage: userMessages[index],
                      assetsStore: chatStore.assetsStore,
                      settingsStore: chatStore.settings,
                    ),
                  ),
                  separatorBuilder: (context, index) => SizedBox(
                    height: chatStore.settings.messageSpacing,
                  ),
                  itemCount: userMessages.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/screens/channel/chat/chat_message.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/widgets/block_button.dart';
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
                title: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: chatStore.auth.isLoggedIn
                    ? BlockButton(
                        authStore: chatStore.auth,
                        targetUser: username,
                        targetUserId: userId,
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
                data: MediaQuery.of(context).copyWith(textScaleFactor: chatStore.settings.fontScale),
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
            )
          ],
        ),
      ),
    );
  }
}

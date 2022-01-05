import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/screens/channel/chat/chat_message.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';
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
    return Scaffold(
      body: SafeArea(
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
              child: ListView(
                reverse: true,
                children: chatStore.messages.reversed
                    .where((message) => message.user == username)
                    .map(
                      (message) => InkWell(
                        onLongPress: () async {
                          await Clipboard.setData(ClipboardData(text: message.message!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message copied!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: ChatMessage(
                          ircMessage: message,
                          assetsStore: chatStore.assetsStore,
                          settingsStore: chatStore.settings,
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

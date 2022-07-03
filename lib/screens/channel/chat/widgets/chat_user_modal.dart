import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/widgets/alert_message.dart';
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
    final name = regexEnglish.hasMatch(widget.displayName) ? widget.displayName : '${widget.displayName} (${widget.username})';

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
                  Flexible(
                    child: Tooltip(
                      preferBelow: false,
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
              onLongPress: () {
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
            if (userMessages.isEmpty)
              const Expanded(child: AlertMessage(message: 'No recent messages'))
            else
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: widget.chatStore.settings.messageScale),
                  child: DefaultTextStyle(
                    style: DefaultTextStyle.of(context).style.copyWith(fontSize: widget.chatStore.settings.fontSize),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      reverse: true,
                      itemBuilder: (context, index) => InkWell(
                        onLongPress: () async {
                          HapticFeedback.lightImpact();

                          await Clipboard.setData(ClipboardData(text: userMessages[index].message));

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: AlertMessage(message: 'Message copied to clipboard'),
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

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/chat_bottom_bar.dart';
import 'package:frosty/screens/channel/chat/chat_message.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';
import 'package:frosty/screens/channel/chat/chat_user_modal.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu.dart';

class Chat extends StatefulWidget {
  final ChatStore chatStore;

  const Chat({Key? key, required this.chatStore}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    final chatStore = widget.chatStore;

    return Observer(
      builder: (context) => Column(
        children: [
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                GestureDetector(
                  onTap: () {
                    // If tapping chat, hide the keyboard and emote menu.
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (chatStore.assetsStore.showEmoteMenu) chatStore.assetsStore.showEmoteMenu = false;
                  },
                  child: Observer(
                    builder: (context) => ListView.builder(
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      itemCount: chatStore.messages.length,
                      controller: chatStore.scrollController,
                      itemBuilder: (context, index) => Observer(
                        builder: (context) {
                          final message = chatStore.messages[index];

                          if (message.user != null && message.user != chatStore.auth.user.details?.login) {
                            return InkWell(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (chatStore.assetsStore.showEmoteMenu) chatStore.assetsStore.showEmoteMenu = false;
                              },
                              onLongPress: () => showModalBottomSheet(
                                context: context,
                                builder: (context) => ChatUserModal(
                                  username: message.user!,
                                  chatStore: chatStore,
                                  userId: message.tags['user-id']!,
                                  displayName: message.tags['display-name']!,
                                ),
                              ),
                              child: ChatMessage(
                                ircMessage: message,
                                assetsStore: chatStore.assetsStore,
                                settingsStore: chatStore.settings,
                              ),
                            );
                          }
                          return ChatMessage(
                            ircMessage: message,
                            assetsStore: chatStore.assetsStore,
                            settingsStore: chatStore.settings,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Observer(
                  builder: (_) => Visibility(
                    visible: !chatStore.autoScroll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: chatStore.resumeScroll,
                        label: const Text('Resume Scroll'),
                        icon: const Icon(Icons.arrow_circle_down),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (chatStore.auth.isLoggedIn) ChatBottomBar(chatStore: chatStore),
          if (chatStore.assetsStore.showEmoteMenu)
            Flexible(
              flex: 2,
              child: EmoteMenu(
                assetsStore: chatStore.assetsStore,
                textController: chatStore.textController,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.chatStore.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_bottom_bar.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_user_modal.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';

class Chat extends StatelessWidget {
  final ChatStore chatStore;

  const Chat({Key? key, required this.chatStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: chatStore.settings.fontScale),
                    child: Observer(
                      builder: (context) => ListView.separated(
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        itemCount: chatStore.messages.length,
                        controller: chatStore.scrollController,
                        separatorBuilder: (context, index) => SizedBox(height: chatStore.settings.messageSpacing),
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
                ),
                Observer(
                  builder: (_) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: chatStore.autoScroll
                        ? const SizedBox()
                        : Container(
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
          const SizedBox(height: 5.0),
          ChatBottomBar(chatStore: chatStore),
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
}

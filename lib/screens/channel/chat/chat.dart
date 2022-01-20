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
            child: GestureDetector(
              onTap: () {
                if (chatStore.assetsStore.showEmoteMenu) {
                  chatStore.assetsStore.showEmoteMenu = false;
                } else if (chatStore.textFieldFocusNode.hasFocus) {
                  chatStore.textFieldFocusNode.unfocus();
                }
              },
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: chatStore.settings.messageScale),
                    child: DefaultTextStyle(
                      style: DefaultTextStyle.of(context).style.copyWith(fontSize: chatStore.settings.fontSize),
                      child: Observer(
                        builder: (context) => ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                                    FocusScope.of(context).unfocus();
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
                          ? null
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
          ),
          ChatBottomBar(chatStore: chatStore),
          if (chatStore.assetsStore.showEmoteMenu)
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
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

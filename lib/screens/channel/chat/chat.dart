import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_bottom_bar.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_user_modal.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/widgets/button.dart';

class Chat extends StatelessWidget {
  final ChatStore chatStore;

  const Chat({Key? key, required this.chatStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Column(
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
                          builder: (context) {
                            final showDividers = chatStore.settings.showChatMessageDividers;

                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: false,
                              itemCount: chatStore.messages.length,
                              controller: chatStore.scrollController,
                              separatorBuilder: (context, index) => showDividers
                                  ? Divider(
                                      height: chatStore.settings.messageSpacing,
                                      thickness: 1.0,
                                    )
                                  : SizedBox(height: chatStore.settings.messageSpacing),
                              itemBuilder: (context, index) => Observer(
                                builder: (context) {
                                  final message = chatStore.messages[index];
                                  final chatMessage = ChatMessage(
                                    ircMessage: message,
                                    assetsStore: chatStore.assetsStore,
                                    settingsStore: chatStore.settings,
                                  );

                                  if (message.user != null && message.user != chatStore.auth.user.details?.login) {
                                    return InkWell(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        if (chatStore.assetsStore.showEmoteMenu) chatStore.assetsStore.showEmoteMenu = false;
                                      },
                                      onLongPress: () => showModalBottomSheet(
                                        context: context,
                                        builder: (context) => ChatUserModal(
                                          chatStore: chatStore,
                                          username: message.user!,
                                          userId: message.tags['user-id']!,
                                          displayName: message.tags['display-name']!,
                                        ),
                                      ),
                                      child: chatMessage,
                                    );
                                  }
                                  return chatMessage;
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Observer(
                      builder: (_) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: chatStore.autoScroll
                            ? null
                            : Button(
                                padding: const EdgeInsets.all(10.0),
                                onPressed: chatStore.resumeScroll,
                                icon: const Icon(Icons.arrow_circle_down),
                                child: const Text('Resume Scroll'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (chatStore.settings.showBottomBar) ChatBottomBar(chatStore: chatStore),
            AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              height: chatStore.assetsStore.showEmoteMenu ? MediaQuery.of(context).size.height / 3 : 0,
              child: chatStore.assetsStore.showEmoteMenu ? EmoteMenu(chatStore: chatStore) : null,
              onEnd: () => chatStore.scrollController.jumpTo(chatStore.scrollController.position.maxScrollExtent),
            ),
          ],
        );
      },
    );
  }
}

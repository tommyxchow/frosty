import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_bottom_bar.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
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
                            return ListView(
                              reverse: true,
                              padding: EdgeInsets.zero,
                              addAutomaticKeepAlives: false,
                              controller: chatStore.scrollController,
                              children: chatStore.renderMessages.reversed
                                  .map((e) => ChatMessage(
                                        ircMessage: e,
                                        chatStore: chatStore,
                                      ))
                                  .toList(),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Observer(
                        builder: (_) => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: chatStore.autoScroll
                              ? null
                              : Button(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                  onPressed: chatStore.resumeScroll,
                                  icon: const Icon(Icons.arrow_circle_down),
                                  child: const Text('Resume Scroll'),
                                ),
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
              child: AnimatedOpacity(
                curve: Curves.ease,
                opacity: chatStore.assetsStore.showEmoteMenu ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: EmoteMenu(chatStore: chatStore),
              ),
            ),
          ],
        );
      },
    );
  }
}

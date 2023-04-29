import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_panel.dart';
import 'package:frosty/screens/channel/chat/emote_menu/recent_emotes_panel.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_bottom_bar.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/page_view.dart';

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
                      data: MediaQuery.of(context).copyWith(
                          textScaleFactor: chatStore.settings.messageScale),
                      child: DefaultTextStyle(
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontSize: chatStore.settings.fontSize),
                        child: Observer(
                          builder: (context) {
                            return ListView.builder(
                              reverse: true,
                              padding: EdgeInsets.zero,
                              addAutomaticKeepAlives: false,
                              controller: chatStore.scrollController,
                              itemCount: chatStore.renderMessages.length,
                              itemBuilder: (context, index) => ChatMessage(
                                ircMessage: chatStore.renderMessages.reversed
                                    .toList()[index],
                                chatStore: chatStore,
                              ),
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
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: chatStore.autoScroll
                              ? null
                              : Button(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  onPressed: chatStore.resumeScroll,
                                  icon: const Icon(
                                      Icons.keyboard_double_arrow_down_rounded),
                                  child: const Text('Resume scroll'),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (chatStore.settings.showBottomBar)
              ChatBottomBar(chatStore: chatStore),
            WillPopScope(
              onWillPop: Platform.isAndroid
                  ? () async {
                      // If pressing the back button on Android while the emote menu is open, close it instead of going back to the streams list.
                      if (chatStore.assetsStore.showEmoteMenu) {
                        chatStore.assetsStore.showEmoteMenu = false;
                        return false;
                      } else {
                        return true;
                      }
                    }
                  : null,
              child: AnimatedContainer(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 200),
                height: chatStore.assetsStore.showEmoteMenu
                    ? MediaQuery.of(context).size.height /
                        (MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 3
                            : 2)
                    : 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: chatStore.assetsStore.showEmoteMenu
                      ? FrostyPageView(
                          headers: const [
                            'Recent',
                            'Twitch',
                            '7TV',
                            'BTTV',
                            'FFZ',
                          ],
                          children: [
                            RecentEmotesPanel(
                              chatStore: chatStore,
                            ),
                            EmoteMenuPanel(
                              chatStore: chatStore,
                              twitchEmotes: chatStore
                                  .assetsStore.userEmoteSectionToEmotes,
                            ),
                            ...[
                              chatStore.assetsStore.sevenTVEmotes,
                              chatStore.assetsStore.bttvEmotes,
                              chatStore.assetsStore.ffzEmotes
                            ].map(
                              (emotes) => EmoteMenuPanel(
                                chatStore: chatStore,
                                emotes: emotes,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

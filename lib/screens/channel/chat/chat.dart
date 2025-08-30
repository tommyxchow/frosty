import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_panel.dart';
import 'package:frosty/screens/channel/chat/emote_menu/recent_emotes_panel.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_bottom_bar.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/utils/orientation_utils.dart';
import 'package:frosty/widgets/page_view.dart';

class Chat extends StatelessWidget {
  final ChatStore chatStore;
  final EdgeInsetsGeometry? listPadding;

  const Chat({super.key, required this.chatStore, this.listPadding});

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
                    chatStore.unfocusInput();
                  }
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler:
                            TextScaler.linear(chatStore.settings.messageScale),
                      ),
                      child: DefaultTextStyle(
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontSize: chatStore.settings.fontSize),
                        child: Scrollbar(
                          controller: chatStore.scrollController,
                          child: Observer(
                            builder: (context) {
                              return ListView.builder(
                                reverse: true,
                                padding: (listPadding ?? EdgeInsets.zero).add(
                                  const EdgeInsets.only(bottom: 64),
                                ),
                                addAutomaticKeepAlives: false,
                                controller: chatStore.scrollController,
                                itemCount: chatStore.renderMessages.length,
                                itemBuilder: (context, index) => ChatMessage(
                                  ircMessage: chatStore.renderMessages[
                                      chatStore.renderMessages.length -
                                          1 -
                                          index],
                                  chatStore: chatStore,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ChatBottomBar(chatStore: chatStore),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        top: 4,
                        right: 4,
                        bottom: 68,
                      ),
                      child: Observer(
                        builder: (_) => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: chatStore.autoScroll
                              ? null
                              : ElevatedButton.icon(
                                  onPressed: chatStore.resumeScroll,
                                  icon:
                                      const Icon(Icons.arrow_downward_rounded),
                                  label: Text(
                                    chatStore.messageBuffer.isNotEmpty
                                        ? '${chatStore.messageBuffer.length} new ${chatStore.messageBuffer.length == 1 ? 'message' : 'messages'}'
                                        : 'Resume scroll',
                                    style: const TextStyle(
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PopScope(
              canPop: Platform.isIOS,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;

                // If pressing the back button on Android while the emote menu
                // is open, close it instead of going back to the streams list.
                if (chatStore.assetsStore.showEmoteMenu) {
                  chatStore.assetsStore.showEmoteMenu = false;
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: AnimatedContainer(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 200),
                height: chatStore.assetsStore.showEmoteMenu
                    ? MediaQuery.of(context).size.height /
                        (context.isPortrait ? 3 : 2)
                    : 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: chatStore.assetsStore.showEmoteMenu
                      ? ClipRect(
                          child: Column(
                            children: [
                              const Divider(),
                              Expanded(
                                child: FrostyPageView(
                                  headers: [
                                    'Recent',
                                    if (chatStore.settings.showTwitchEmotes)
                                      'Twitch',
                                    if (chatStore.settings.show7TVEmotes) '7TV',
                                    if (chatStore.settings.showBTTVEmotes)
                                      'BTTV',
                                    if (chatStore.settings.showFFZEmotes) 'FFZ',
                                  ],
                                  children: [
                                    RecentEmotesPanel(
                                      chatStore: chatStore,
                                    ),
                                    if (chatStore.settings.showTwitchEmotes)
                                      EmoteMenuPanel(
                                        chatStore: chatStore,
                                        twitchEmotes: chatStore.assetsStore
                                            .userEmoteSectionToEmotes,
                                      ),
                                    ...[
                                      if (chatStore.settings.show7TVEmotes)
                                        chatStore.assetsStore.sevenTVEmotes,
                                      if (chatStore.settings.showBTTVEmotes)
                                        chatStore.assetsStore.bttvEmotes,
                                      if (chatStore.settings.showFFZEmotes)
                                        chatStore.assetsStore.ffzEmotes,
                                    ].map(
                                      (emotes) => EmoteMenuPanel(
                                        chatStore: chatStore,
                                        emotes: emotes,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_panel.dart';

class EmoteMenu extends StatelessWidget {
  final ChatStore chatStore;

  const EmoteMenu({Key? key, required this.chatStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const sections = [
      "Twitch",
      "BTTV",
      "FFZ",
      "7TV",
    ];

    final pageContoller = PageController();

    return Column(
      children: [
        Expanded(
          child: PageView(
            onPageChanged: (index) => chatStore.emoteMenuIndex = index,
            controller: pageContoller,
            children: [
              Observer(
                builder: (_) => EmoteMenuPanel(
                  textController: chatStore.textController,
                  emotes: chatStore.userEmoteToObject.values.toList(),
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  textController: chatStore.textController,
                  emotes: chatStore.bttvEmotes,
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  textController: chatStore.textController,
                  emotes: chatStore.ffzEmotes,
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  textController: chatStore.textController,
                  emotes: chatStore.sevenTvEmotes,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sections
              .mapIndexed(
                (index, section) => Observer(
                  builder: (context) => TextButton(
                    onPressed: () {
                      pageContoller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                      chatStore.emoteMenuIndex = index;
                    },
                    style: index == chatStore.emoteMenuIndex ? null : TextButton.styleFrom(primary: Colors.grey),
                    child: Text(section),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

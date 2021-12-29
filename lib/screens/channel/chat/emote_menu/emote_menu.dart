import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/chat_assets_store.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_panel.dart';

class EmoteMenu extends StatelessWidget {
  final ChatAssetsStore assetsStore;
  final TextEditingController textController;

  const EmoteMenu({Key? key, required this.assetsStore, required this.textController}) : super(key: key);

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
            onPageChanged: (index) => assetsStore.emoteMenuIndex = index,
            controller: pageContoller,
            children: [
              Observer(
                builder: (_) => EmoteMenuPanel(
                  textController: textController,
                  emotes: assetsStore.userEmoteToObject.values.toList(),
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  textController: textController,
                  emotes: assetsStore.bttvEmotes,
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  textController: textController,
                  emotes: assetsStore.ffzEmotes,
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  textController: textController,
                  emotes: assetsStore.sevenTvEmotes,
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
                      assetsStore.emoteMenuIndex = index;
                    },
                    style: index == assetsStore.emoteMenuIndex ? null : TextButton.styleFrom(primary: Colors.grey),
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

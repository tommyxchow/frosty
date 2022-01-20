import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_panel.dart';
import 'package:frosty/screens/channel/chat/emote_menu/recent_emotes_panel.dart';
import 'package:frosty/screens/channel/stores/chat_assets_store.dart';

class EmoteMenu extends StatefulWidget {
  final ChatAssetsStore assetsStore;
  final TextEditingController textController;

  const EmoteMenu({
    Key? key,
    required this.assetsStore,
    required this.textController,
  }) : super(key: key);

  @override
  State<EmoteMenu> createState() => _EmoteMenuState();
}

class _EmoteMenuState extends State<EmoteMenu> {
  late final PageController pageContoller;

  @override
  void initState() {
    pageContoller = PageController(initialPage: widget.assetsStore.emoteMenuIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const sections = [
      "Recent",
      "Twitch",
      "BTTV",
      "FFZ",
      "7TV",
    ];

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sections
                .mapIndexed(
                  (index, section) => Observer(
                    builder: (context) => TextButton(
                      onPressed: () {
                        pageContoller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        );
                        widget.assetsStore.emoteMenuIndex = index;
                      },
                      style: index == widget.assetsStore.emoteMenuIndex ? null : TextButton.styleFrom(primary: Colors.grey),
                      child: Text(section),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: PageView(
            onPageChanged: (index) => widget.assetsStore.emoteMenuIndex = index,
            controller: pageContoller,
            children: [
              RecentEmotesPanel(
                assetsStore: widget.assetsStore,
                textController: widget.textController,
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  assetsStore: widget.assetsStore,
                  textController: widget.textController,
                  emotes: widget.assetsStore.userEmoteToObject.values.toList(),
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  assetsStore: widget.assetsStore,
                  textController: widget.textController,
                  emotes: widget.assetsStore.bttvEmotes,
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  assetsStore: widget.assetsStore,
                  textController: widget.textController,
                  emotes: widget.assetsStore.ffzEmotes,
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  assetsStore: widget.assetsStore,
                  textController: widget.textController,
                  emotes: widget.assetsStore.sevenTVEmotes,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    pageContoller.dispose();
    super.dispose();
  }
}

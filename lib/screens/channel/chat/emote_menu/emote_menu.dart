import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_panel.dart';
import 'package:frosty/screens/channel/chat/emote_menu/recent_emotes_panel.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/widgets/button.dart';

class EmoteMenu extends StatefulWidget {
  final ChatStore chatStore;

  const EmoteMenu({
    Key? key,
    required this.chatStore,
  }) : super(key: key);

  @override
  State<EmoteMenu> createState() => _EmoteMenuState();
}

class _EmoteMenuState extends State<EmoteMenu> {
  late final PageController _pageContoller = PageController(initialPage: widget.chatStore.assetsStore.emoteMenuIndex);

  @override
  Widget build(BuildContext context) {
    const sections = [
      'RECENT',
      'TWITCH',
      'BTTV',
      'FFZ',
      '7TV',
    ];

    final emoteMenu = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          height: 5.0,
          thickness: 1.0,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...sections.mapIndexed(
                (index, section) => Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Observer(
                    builder: (context) => Button(
                      onPressed: () {
                        _pageContoller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        );
                        widget.chatStore.assetsStore.emoteMenuIndex = index;
                      },
                      color: index == widget.chatStore.assetsStore.emoteMenuIndex ? Theme.of(context).colorScheme.secondary : Colors.grey,
                      child: Text(
                        section,
                        style: const TextStyle(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            onPageChanged: (index) => widget.chatStore.assetsStore.emoteMenuIndex = index,
            controller: _pageContoller,
            children: [
              RecentEmotesPanel(
                chatStore: widget.chatStore,
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  chatStore: widget.chatStore,
                  twitchEmotes: widget.chatStore.assetsStore.userEmoteSectionToEmotes,
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  chatStore: widget.chatStore,
                  emotes: widget.chatStore.assetsStore.bttvEmotes,
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  chatStore: widget.chatStore,
                  emotes: widget.chatStore.assetsStore.ffzEmotes,
                ),
              ),
              Observer(
                builder: (_) => EmoteMenuPanel(
                  chatStore: widget.chatStore,
                  emotes: widget.chatStore.assetsStore.sevenTVEmotes,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (Platform.isAndroid) {
      return WillPopScope(
        onWillPop: () async {
          // If pressing the back button on Android while the emote menu is open, close it instead of going back to the streams list.
          if (widget.chatStore.assetsStore.showEmoteMenu) {
            widget.chatStore.assetsStore.showEmoteMenu = false;
            return false;
          } else {
            return true;
          }
        },
        child: emoteMenu,
      );
    }

    return emoteMenu;
  }

  @override
  void dispose() {
    _pageContoller.dispose();
    super.dispose();
  }
}

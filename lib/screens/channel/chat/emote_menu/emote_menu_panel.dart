import 'package:flutter/material.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_section.dart';

class EmoteMenuPanel extends StatelessWidget {
  final TextEditingController textController;
  final List<Emote> emotes;

  const EmoteMenuPanel({Key? key, required this.textController, required this.emotes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    const headerPadding = EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 5.0);

    final globalEmotes = emotes
        .where((emote) =>
            emote.type == EmoteType.twitchGlobal ||
            emote.type == EmoteType.bttvGlobal ||
            emote.type == EmoteType.ffzGlobal ||
            emote.type == EmoteType.sevenTvGlobal)
        .toList();

    final channelEmotes = emotes
        .where((emote) =>
            emote.type == EmoteType.twitchChannel ||
            emote.type == EmoteType.bttvChannel ||
            emote.type == EmoteType.bttvShared ||
            emote.type == EmoteType.ffzChannel ||
            emote.type == EmoteType.sevenTvChannel)
        .toList();

    final subEmotes = emotes.where((emote) => emote.type == EmoteType.twitchSub).toList();
    final miscEmotes = emotes.where((emote) => emote.type == EmoteType.twitchUnlocked).toList();

    return CustomScrollView(
      slivers: [
        if (globalEmotes.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: Text(
                'Global Emotes',
                style: headerStyle,
              ),
            ),
          ),
          EmoteMenuSection(
            textController: textController,
            emotes: globalEmotes,
          ),
        ],
        if (channelEmotes.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: headerPadding,
              child: Text(
                'Channel Emotes',
                style: headerStyle,
              ),
            ),
          ),
          EmoteMenuSection(
            textController: textController,
            emotes: channelEmotes,
          ),
        ],
        if (subEmotes.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: headerPadding,
              child: Text(
                'Subbed Emotes',
                style: headerStyle,
              ),
            ),
          ),
          EmoteMenuSection(
            textController: textController,
            emotes: subEmotes,
          ),
        ],
        if (miscEmotes.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: headerPadding,
              child: Text(
                'Unlocked Emotes',
                style: headerStyle,
              ),
            ),
          ),
          EmoteMenuSection(
            textController: textController,
            emotes: miscEmotes,
          ),
        ],
      ],
    );
  }
}

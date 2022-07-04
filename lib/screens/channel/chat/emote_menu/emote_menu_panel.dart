import 'package:flutter/material.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_section.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/widgets/section_header.dart';

class EmoteMenuPanel extends StatelessWidget {
  final ChatStore chatStore;
  final List<Emote>? emotes;
  final Map<String, List<Emote>>? twitchEmotes;

  const EmoteMenuPanel({
    Key? key,
    required this.chatStore,
    this.emotes,
    this.twitchEmotes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (emotes != null) {
      final globalEmotes =
          emotes!.where((emote) => emote.type == EmoteType.bttvGlobal || emote.type == EmoteType.ffzGlobal || emote.type == EmoteType.sevenTVGlobal).toList();

      final channelEmotes = emotes!
          .where((emote) =>
              emote.type == EmoteType.bttvChannel ||
              emote.type == EmoteType.bttvShared ||
              emote.type == EmoteType.ffzChannel ||
              emote.type == EmoteType.sevenTVChannel)
          .toList();

      return CustomScrollView(
        slivers: [
          if (globalEmotes.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(
                'Global Emotes',
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              ),
            ),
            EmoteMenuSection(
              chatStore: chatStore,
              emotes: globalEmotes,
            ),
          ],
          if (channelEmotes.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader('Channel Emotes'),
            ),
            EmoteMenuSection(
              chatStore: chatStore,
              emotes: channelEmotes,
            ),
          ],
        ],
      );
    } else {
      return CustomScrollView(
        slivers: [
          for (final entry in twitchEmotes!.entries) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                entry.key,
                padding: entry.key == 'Global Emotes' ? const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0) : null,
              ),
            ),
            EmoteMenuSection(
              chatStore: chatStore,
              emotes: entry.value,
            ),
          ]
        ],
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_section.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/widgets/frosty_page_view.dart';

class EmoteMenuPanel extends StatelessWidget {
  final ChatStore chatStore;
  final List<Emote>? emotes;
  final Map<String, List<Emote>>? twitchEmotes;

  const EmoteMenuPanel({
    super.key,
    required this.chatStore,
    this.emotes,
    this.twitchEmotes,
  });

  @override
  Widget build(BuildContext context) {
    if (emotes != null) {
      final globalEmotes = emotes!
          .where(
            (emote) =>
                emote.type == EmoteType.bttvGlobal ||
                emote.type == EmoteType.ffzGlobal ||
                emote.type == EmoteType.sevenTVGlobal,
          )
          .toList();

      final channelEmotes = emotes!
          .where(
            (emote) =>
                emote.type == EmoteType.bttvChannel ||
                emote.type == EmoteType.bttvShared ||
                emote.type == EmoteType.ffzChannel ||
                emote.type == EmoteType.sevenTVChannel,
          )
          .toList();

      return FrostyPageView(
        headers: [if (channelEmotes.isNotEmpty) 'Channel', 'Global'],
        children: [
          if (channelEmotes.isNotEmpty)
            EmoteMenuSection(chatStore: chatStore, emotes: channelEmotes),
          EmoteMenuSection(chatStore: chatStore, emotes: globalEmotes),
        ],
      );
    } else {
      final isSubbed = chatStore.userState.subscriber;

      twitchEmotes?.removeWhere(
        (key, value) => key.toLowerCase() == chatStore.channelName,
      );

      return FrostyPageView(
        headers: twitchEmotes!.keys
            .map((header) => header.split(' ')[0])
            .toList(),
        children: twitchEmotes!.entries
            .map(
              (e) {
                final isChannelSection = e.key.contains('Channel');
                bool sectionDisabled = false;
                
                if (isChannelSection && !isSubbed) {
                  final hasAccessibleEmotes = e.value.any((emote) => 
                      emote.type == EmoteType.twitchFollower || 
                      emote.type == EmoteType.twitchBits || 
                      emote.type == EmoteType.twitchUnlocked);
                      
                  sectionDisabled = !hasAccessibleEmotes;
                }

                // We sort the emotes: first the follower, then subscriber emotes
                final sortedEmotes = List<Emote>.from(e.value);
                sortedEmotes.sort((a, b) {
                  int getWeight(EmoteType type) {
                    if (type == EmoteType.twitchFollower) return 0;
                    if (type == EmoteType.twitchUnlocked) return 1;
                    if (type == EmoteType.twitchBits) return 2;
                    if (type == EmoteType.twitchSub) return 3;
                    return 4; // fallback
                  }
                  return getWeight(a.type).compareTo(getWeight(b.type));
                });

                return EmoteMenuSection(
                  chatStore: chatStore,
                  emotes: sortedEmotes,
                  disabled: sectionDisabled,
                );
              },
            )
            .toList(),
      );
    }
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:provider/provider.dart';

class RecentEmotesPanel extends StatelessWidget {
  final ChatStore chatStore;

  const RecentEmotesPanel({
    Key? key,
    required this.chatStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (chatStore.assetsStore.recentEmotes.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: AlertMessage(message: 'No recent emotes'),
          )
        else
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait
                  ? 8
                  : context.read<SettingsStore>().showVideo
                      ? 6
                      : 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final emote = chatStore.assetsStore.recentEmotes[index];
                final validEmotes = [
                  ...chatStore.assetsStore.emoteToObject.values,
                  ...chatStore.assetsStore.userEmoteToObject.values
                ];
                final matchingEmotes = validEmotes
                    .where((existingEmote) => existingEmote.name == emote.name && existingEmote.type == emote.type);

                return InkWell(
                  onTap: matchingEmotes.isNotEmpty ? () => chatStore.addEmote(emote) : null,
                  child: Tooltip(
                    message: emote.name,
                    preferBelow: false,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: matchingEmotes.isNotEmpty ? matchingEmotes.first.url : emote.url,
                          color: matchingEmotes.isNotEmpty ? null : const Color.fromRGBO(255, 255, 255, 0.5),
                          colorBlendMode: matchingEmotes.isNotEmpty ? null : BlendMode.modulate,
                          height: emote.height?.toDouble() ?? defaultEmoteSize,
                          width: emote.width?.toDouble(),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: chatStore.assetsStore.recentEmotes.length,
            ),
          ),
      ],
    );
  }
}

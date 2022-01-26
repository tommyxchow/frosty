import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/stores/chat_assets_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:provider/provider.dart';

class RecentEmotesPanel extends StatelessWidget {
  final ChatAssetsStore assetsStore;
  final TextEditingController textController;

  const RecentEmotesPanel({
    Key? key,
    required this.assetsStore,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: SectionHeader(
            'Recent Emotes',
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(10.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait
                  ? 8
                  : context.read<SettingsStore>().showVideo
                      ? 6
                      : 16,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final emote = assetsStore.recentEmotes[index];
                final validEmotes = [...assetsStore.emoteToObject.values, ...assetsStore.userEmoteToObject.values];
                final matchingEmotes = validEmotes.where((existingEmote) => existingEmote.name == emote.name);

                return GestureDetector(
                  onTap: matchingEmotes.isNotEmpty
                      ? () {
                          textController.text += ' ' + emote.name;
                          assetsStore.recentEmotes.removeWhere((recentEmote) => recentEmote.name == matchingEmotes.first.name);
                          assetsStore.recentEmotes.insert(0, matchingEmotes.first);
                        }
                      : null,
                  child: Tooltip(
                    message: emote.name,
                    preferBelow: false,
                    child: CachedNetworkImage(
                      imageUrl: matchingEmotes.isNotEmpty ? matchingEmotes.first.url : emote.url,
                      color: matchingEmotes.isNotEmpty ? null : const Color.fromRGBO(255, 255, 255, 0.5),
                      colorBlendMode: matchingEmotes.isNotEmpty ? null : BlendMode.modulate,
                    ),
                  ),
                );
              },
              childCount: assetsStore.recentEmotes.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
            ),
          ),
        ),
      ],
    );
  }
}

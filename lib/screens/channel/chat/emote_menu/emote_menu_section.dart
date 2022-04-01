import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:provider/provider.dart';

class EmoteMenuSection extends StatelessWidget {
  final ChatStore chatStore;
  final List<Emote> emotes;

  const EmoteMenuSection({
    Key? key,
    required this.chatStore,
    required this.emotes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
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
          (context, index) => GestureDetector(
            onTap: () => chatStore.addEmote(emotes[index]),
            child: Tooltip(
              message: emotes[index].name,
              preferBelow: false,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: emotes[index].url,
                  height: emotes[index].height?.toDouble() ?? defaultEmoteSize,
                  width: emotes[index].width?.toDouble(),
                ),
              ),
            ),
          ),
          childCount: emotes.length,
        ),
      ),
    );
  }
}

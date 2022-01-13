import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:provider/provider.dart';

class EmoteMenuSection extends StatelessWidget {
  final TextEditingController textController;
  final List<Emote> emotes;

  const EmoteMenuSection({
    Key? key,
    required this.textController,
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
          (context, index) {
            return GestureDetector(
              onTap: () => textController.text += ' ' + emotes[index].name,
              child: Tooltip(
                message: emotes[index].name,
                preferBelow: false,
                child: CachedNetworkImage(imageUrl: emotes[index].url),
              ),
            );
          },
          childCount: emotes.length,
        ),
      ),
    );
  }
}

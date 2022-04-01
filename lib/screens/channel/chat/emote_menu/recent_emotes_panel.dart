import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:provider/provider.dart';

class RecentEmotesPanel extends StatefulWidget {
  final ChatStore chatStore;

  const RecentEmotesPanel({
    Key? key,
    required this.chatStore,
  }) : super(key: key);

  @override
  State<RecentEmotesPanel> createState() => _RecentEmotesPanelState();
}

class _RecentEmotesPanelState extends State<RecentEmotesPanel> {
  Future<void> _showClearDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cler Recent Emotes'),
        content: const Text('Are you sure you want to clear your recent emotes?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
            style: TextButton.styleFrom(primary: Colors.red),
          ),
          ElevatedButton(
            onPressed: () {
              setState(widget.chatStore.assetsStore.recentEmotes.clear);
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              const SectionHeader(
                'Recent Emotes',
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              ),
              const Spacer(),
              SizedBox(
                height: 30,
                child: TextButton(
                  onPressed: widget.chatStore.assetsStore.recentEmotes.isEmpty ? null : _showClearDialog,
                  child: const Text('Clear'),
                ),
              ),
            ],
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
                final emote = widget.chatStore.assetsStore.recentEmotes[index];
                final validEmotes = [...widget.chatStore.assetsStore.emoteToObject.values, ...widget.chatStore.assetsStore.userEmoteToObject.values];
                final matchingEmotes = validEmotes.where((existingEmote) => existingEmote.name == emote.name && existingEmote.type == emote.type);

                return GestureDetector(
                  onTap: matchingEmotes.isNotEmpty ? () => widget.chatStore.addEmote(emote) : null,
                  child: Tooltip(
                    message: emote.name,
                    preferBelow: false,
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
                );
              },
              childCount: widget.chatStore.assetsStore.recentEmotes.length,
            ),
          ),
        ),
      ],
    );
  }
}

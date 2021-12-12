import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/models/emotes.dart';

import 'chat_store.dart';

class EmoteMenu extends StatelessWidget {
  final ChatStore chatStore;
  final EmoteType emoteType;

  const EmoteMenu({Key? key, required this.chatStore, required this.emoteType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emotes = chatStore.emoteToObject.values.toList().where((emote) => emote.type == emoteType).toList();
    return SizedBox(
      height: MediaQuery.of(context).size.height / 4,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        padding: const EdgeInsets.all(10.0),
        itemCount: emotes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: emoteType == EmoteType.twitchChannel && !chatStore.userState.subscriber
                ? null
                : () => chatStore.textController.text += ' ' + emotes[index].name,
            child: Tooltip(
              message: emotes[index].name,
              preferBelow: false,
              child: CachedNetworkImage(
                imageUrl: emotes[index].url,
                color: emoteType == EmoteType.twitchChannel && !chatStore.userState.subscriber ? const Color.fromRGBO(255, 255, 255, 0.5) : null,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          );
        },
      ),
    );
  }
}

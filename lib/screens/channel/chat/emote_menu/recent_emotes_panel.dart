import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:provider/provider.dart';

class RecentEmotesPanel extends StatelessWidget {
  final ChatStore chatStore;

  const RecentEmotesPanel({
    super.key,
    required this.chatStore,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            if (chatStore.assetsStore.recentEmotes.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AlertMessage(message: 'No recent emotes'),
              )
            else
              SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? 8
                          : context.read<SettingsStore>().showVideo
                              ? 6
                              : 16,
                ),
                itemBuilder: (context, index) {
                  final emote = chatStore.assetsStore.recentEmotes[index];
                  final validEmotes = [
                    ...chatStore.assetsStore.emoteToObject.values,
                    ...chatStore.assetsStore.userEmoteToObject.values,
                  ];
                  final matchingEmotes = validEmotes.where(
                    (existingEmote) =>
                        existingEmote.name == emote.name &&
                        existingEmote.type == emote.type,
                  );

                  return InkWell(
                    onTap: matchingEmotes.isNotEmpty
                        ? () => chatStore.addEmote(emote)
                        : null,
                    onLongPress: () {
                      HapticFeedback.lightImpact();

                      IRCMessage.showEmoteDetailsBottomSheet(
                        context,
                        emote: emote,
                        launchExternal: chatStore.settings.launchUrlExternal,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: FrostyCachedNetworkImage(
                          imageUrl: matchingEmotes.isNotEmpty
                              ? matchingEmotes.first.url
                              : emote.url,
                          color: matchingEmotes.isNotEmpty
                              ? null
                              : const Color.fromRGBO(255, 255, 255, 0.5),
                          colorBlendMode: matchingEmotes.isNotEmpty
                              ? null
                              : BlendMode.modulate,
                          height: emote.height?.toDouble() ?? defaultEmoteSize,
                          width: emote.width?.toDouble(),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: chatStore.assetsStore.recentEmotes.length,
              ),
          ],
        );
      },
    );
  }
}

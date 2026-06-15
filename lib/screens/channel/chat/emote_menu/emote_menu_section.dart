import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/widgets/frosty_cached_network_image.dart';

class EmoteMenuSection extends StatefulWidget {
  final ChatStore chatStore;
  final List<Emote> emotes;
  final bool disabled;

  const EmoteMenuSection({
    super.key,
    required this.chatStore,
    required this.emotes,
    this.disabled = false,
  });

  @override
  State<EmoteMenuSection> createState() => _EmoteMenuSectionState();
}

class _EmoteMenuSectionState extends State<EmoteMenuSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.isPortrait
              ? 8
              : context.settingsStore.showVideo
              ? 6
              : 16,
        ),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          // Observer wraps emotes: greyscale not available emotes
          return Observer(
            builder: (context) {
              final emote = widget.emotes[index];
              final isSubbed = widget.chatStore.userState.subscriber;
              final isFollowing = widget.chatStore.isFollowing;
              
              final isSubEmote = emote.type == EmoteType.twitchSub || emote.type == EmoteType.twitchChannel;
              final isFollowerEmote = emote.type == EmoteType.twitchFollower;

              // Idea:
              // 1. Section completly deactivated? -> grey emote
              // 2. Sub-emote, but user isn't Sub? -> grey emote
              // 3. Follower-emote, but user not Sub and not Follower? -> grey emote
              final isEmoteDisabled = widget.disabled || 
                  (isSubEmote && !isSubbed) || 
                  (isFollowerEmote && !isFollowing && !isSubbed);

              return InkWell(
                onTap: isEmoteDisabled
                    ? null
                    : () => widget.chatStore.addEmote(emote),
                onLongPress: () {
                  HapticFeedback.lightImpact();

                  IRCMessage.showEmoteDetailsBottomSheet(
                    context,
                    emote: emote,
                    launchExternal: widget.chatStore.settings.launchUrlExternal,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: FrostyCachedNetworkImage(
                      imageUrl: emote.url,
                      height: emote.height?.toDouble() ?? defaultEmoteSize,
                      width: emote.width?.toDouble(),
                      // Color to grey-ish when disabled
                      color: isEmoteDisabled
                          ? const Color.fromRGBO(255, 255, 255, 0.5)
                          : null,
                      colorBlendMode: isEmoteDisabled ? BlendMode.modulate : null,
                    ),
                  ),
                ),
              );
            },
          );
        },
        itemCount: widget.emotes.length,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

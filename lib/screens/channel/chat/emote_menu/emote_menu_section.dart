import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:provider/provider.dart';

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

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? 8
                : context.read<SettingsStore>().showVideo
                    ? 6
                    : 16,
      ),
      itemBuilder: (context, index) => InkWell(
        onTap: widget.disabled
            ? null
            : () => widget.chatStore.addEmote(widget.emotes[index]),
        onLongPress: () {
          HapticFeedback.lightImpact();

          IRCMessage.showEmoteDetailsBottomSheet(
            context,
            emote: widget.emotes[index],
            launchExternal: widget.chatStore.settings.launchUrlExternal,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: FrostyCachedNetworkImage(
              imageUrl: widget.emotes[index].url,
              height:
                  widget.emotes[index].height?.toDouble() ?? defaultEmoteSize,
              width: widget.emotes[index].width?.toDouble(),
              color: widget.disabled
                  ? const Color.fromRGBO(255, 255, 255, 0.5)
                  : null,
              colorBlendMode: widget.disabled ? BlendMode.modulate : null,
            ),
          ),
        ),
      ),
      itemCount: widget.emotes.length,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/details/chat_details.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:frosty/widgets/chat_input/emote_text_span_builder.dart';
import 'package:frosty/widgets/frosty_cached_network_image.dart';

class ChatBottomBar extends StatelessWidget {
  final ChatStore chatStore;

  /// Callback to add a new chat tab.
  /// Passes this to ChatDetails to show "Add chat" option.
  final VoidCallback onAddChat;

  const ChatBottomBar({
    super.key,
    required this.chatStore,
    required this.onAddChat,
  });

  @override
  Widget build(BuildContext context) {
    final isEmotesEnabled =
        chatStore.settings.showTwitchEmotes ||
        chatStore.settings.show7TVEmotes ||
        chatStore.settings.showBTTVEmotes ||
        chatStore.settings.showFFZEmotes;

    final emoteMenuButton = isEmotesEnabled
        ? Tooltip(
            message: 'Emote menu',
            preferBelow: false,
            child: IconButton(
              color: chatStore.assetsStore.showEmoteMenu
                  ? Theme.of(context).colorScheme.secondary
                  : null,
              icon: Icon(
                chatStore.assetsStore.showEmoteMenu
                    ? Icons.emoji_emotions_rounded
                    : Icons.emoji_emotions_outlined,
              ),
              onPressed: () {
                chatStore.unfocusInput();
                chatStore.assetsStore.showEmoteMenu =
                    !chatStore.assetsStore.showEmoteMenu;
              },
            ),
          )
        : null;

    return Observer(
      builder: (context) {
        final matchingEmotes = chatStore.matchingEmotes;
        final matchingChatters = chatStore.matchingChatters;

        final isFullscreenOverlay =
            chatStore.settings.fullScreen && context.isLandscape;

        // Check if chat delay is active (for indicator only, doesn't block input)
        final hasChatDelay =
            chatStore.settings.showVideo && chatStore.settings.chatDelay > 0;

        const loginTooltipMessage = 'Log in to chat';

        final bottomBarContent = Column(
          children: [
            if (chatStore.replyingToMessage != null) ...[
              const Divider(),
              TextFieldTapRegion(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 4,
                      ),
                    ),
                  ),
                  // Left: 8px so text aligns at 12px (4px border + 8px padding)
                  // Right: 4px to give close button some breathing room
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Tooltip(
                          message: chatStore.replyingToMessage!.message ?? '',
                          preferBelow: false,
                          child: Text.rich(
                            TextSpan(
                              children:
                                  chatStore.replyingToMessage!.generateSpan(
                                context,
                                assetsStore: chatStore.assetsStore,
                                emoteScale: chatStore.settings.emoteScale,
                                badgeScale: chatStore.settings.badgeScale,
                                launchExternal:
                                    chatStore.settings.launchUrlExternal,
                                timestamp: chatStore.settings.timestampType,
                                currentChannelId: chatStore.channelId,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.defaultTextStyle.copyWith(
                              fontSize: chatStore.settings.fontSize,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cancel reply',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => chatStore.replyingToMessage = null,
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Wrap autocomplete sections with TextFieldTapRegion so taps
            // on them don't trigger TextField's onTapOutside callback.
            if (chatStore.settings.autocomplete &&
                chatStore.showEmoteAutocomplete &&
                matchingEmotes.isNotEmpty) ...[
              const Divider(),
              TextFieldTapRegion(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(4),
                    itemCount: matchingEmotes.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () => chatStore.addEmote(
                        matchingEmotes[index],
                        autocompleteMode: true,
                      ),
                      onLongPress: () {
                        HapticFeedback.lightImpact();

                        IRCMessage.showEmoteDetailsBottomSheet(
                          context,
                          emote: matchingEmotes[index],
                          launchExternal: chatStore.settings.launchUrlExternal,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: FrostyCachedNetworkImage(
                            imageUrl: matchingEmotes[index].url,
                            useFade: false,
                            height:
                                matchingEmotes[index].height?.toDouble() ??
                                defaultEmoteSize,
                            width: matchingEmotes[index].width?.toDouble(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (chatStore.settings.autocomplete &&
                chatStore.showMentionAutocomplete &&
                matchingChatters.isNotEmpty) ...[
              const Divider(),
              TextFieldTapRegion(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(4),
                    itemCount: matchingChatters.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        final split = chatStore.textController.text.split(' ')
                          ..removeLast()
                          ..add('@${matchingChatters[index]} ');

                        chatStore.textController.text = split.join(' ');
                        chatStore.textController.selection =
                            TextSelection.fromPosition(
                              TextPosition(
                                offset: chatStore.textController.text.length,
                              ),
                            );
                      },
                      child: Text(matchingChatters[index]),
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: Row(
                children: [
                  if (!chatStore.expandChat &&
                      chatStore.settings.chatWidth < 0.3 &&
                      chatStore.settings.showVideo &&
                      context.isLandscape)
                    Builder(
                      builder: (context) {
                        final isDisabled = !chatStore.auth.isLoggedIn;

                        return GestureDetector(
                          onTap: isDisabled
                              ? () {
                                  chatStore.updateNotification(
                                    loginTooltipMessage,
                                  );
                                }
                              : null,
                          child: IconButton(
                            tooltip: 'Enter a message',
                            onPressed: isDisabled
                                ? null
                                : () {
                                    chatStore.expandChat = true;
                                    chatStore.safeRequestFocus();
                                  },
                            icon: const Icon(Icons.edit),
                          ),
                        );
                      },
                    )
                  else
                    Expanded(
                      child: Observer(
                        builder: (context) {
                          final isLoggedIn = chatStore.auth.isLoggedIn;
                          final isWaitingForAck = chatStore.isWaitingForAck;
                          final isEnabled = isLoggedIn && !isWaitingForAck;

                          return GestureDetector(
                            onTap: !isLoggedIn
                                ? () {
                                    chatStore.updateNotification(
                                      loginTooltipMessage,
                                    );
                                  }
                                : null,
                            child: ExtendedTextField(
                              textInputAction: TextInputAction.send,
                              focusNode: chatStore.textFieldFocusNode,
                              minLines: 1,
                              maxLines: 3,
                              enabled: isEnabled,
                              specialTextSpanBuilder: EmoteTextSpanBuilder(
                                emoteToObject: chatStore.assetsStore.emoteToObject,
                                userEmoteToObject:
                                    chatStore.assetsStore.userEmoteToObject,
                                emoteSize:
                                    chatStore.settings.emoteScale * defaultEmoteSize,
                              ),
                              decoration: InputDecoration(
                                prefixIcon:
                                    chatStore.settings.emoteMenuButtonOnLeft
                                    ? emoteMenuButton
                                    : null,
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 8,
                                  children: [
                                    if (!chatStore
                                            .settings
                                            .emoteMenuButtonOnLeft &&
                                        emoteMenuButton != null)
                                      emoteMenuButton,
                                  ],
                                ),
                                hintMaxLines: 1,
                                hintText: isLoggedIn
                                    ? isWaitingForAck
                                        ? 'Sending...'
                                        : chatStore.replyingToMessage != null
                                            ? 'Reply'
                                            : hasChatDelay
                                                ? 'Chat (${chatStore.settings.chatDelay.toInt()}s delay)'
                                                : 'Chat'
                                    : loginTooltipMessage,
                              ),
                              controller: chatStore.textController,
                              onSubmitted: chatStore.sendMessage,
                              onTapOutside: (_) {
                                chatStore.textFieldFocusNode.unfocus();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  TextFieldTapRegion(
                    child: chatStore.showSendButton &&
                            (chatStore.settings.chatWidth >= 0.3 ||
                                chatStore.expandChat ||
                                context.isPortrait)
                        ? Observer(
                            builder: (context) => IconButton(
                              tooltip: chatStore.isWaitingForAck
                                  ? 'Sending...'
                                  : 'Send',
                              icon: chatStore.isWaitingForAck
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              onPressed:
                                  chatStore.auth.isLoggedIn &&
                                      !chatStore.isWaitingForAck
                                  ? () => chatStore.sendMessage(
                                      chatStore.textController.text,
                                    )
                                  : null,
                            ),
                          )
                        : IconButton(
                            icon: Icon(Icons.adaptive.more_rounded),
                            tooltip: 'More',
                            onPressed: () => showModalBottomSheetWithProperFocus(
                              isScrollControlled: true,
                              context: context,
                              builder: (_) => ChatDetails(
                                chatDetailsStore: chatStore.chatDetailsStore,
                                chatStore: chatStore,
                                userLogin: chatStore.channelName,
                                onAddChat: onAddChat,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );

        return isFullscreenOverlay
            ? Padding(
                padding: EdgeInsets.only(
                  bottom: chatStore.assetsStore.showEmoteMenu
                      ? 0
                      : MediaQuery.of(context).padding.bottom,
                ),
                child: bottomBarContent,
              )
            : BlurredContainer(
                gradientDirection: GradientDirection.down,
                padding: EdgeInsets.only(
                  bottom: chatStore.assetsStore.showEmoteMenu
                      ? 0
                      : MediaQuery.of(context).padding.bottom,
                ),
                child: bottomBarContent,
              );
      },
    );
  }
}

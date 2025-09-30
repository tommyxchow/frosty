import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/details/chat_details.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:frosty/widgets/cached_image.dart';

class ChatBottomBar extends StatelessWidget {
  final ChatStore chatStore;

  const ChatBottomBar({super.key, required this.chatStore});

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
        final matchingEmotes =
            [
                  ...chatStore.assetsStore.userEmoteToObject.values,
                  ...chatStore.assetsStore.bttvEmotes,
                  ...chatStore.assetsStore.ffzEmotes,
                  ...chatStore.assetsStore.sevenTVEmotes,
                ]
                .where(
                  (emote) => emote.name.toLowerCase().contains(
                    chatStore.inputText.split(' ').last.toLowerCase(),
                  ),
                )
                .toList();

        final matchingChatters = chatStore.chatDetailsStore.chatUsers
            .where(
              (chatter) => chatter.contains(
                chatStore.inputText
                    .split(' ')
                    .last
                    .replaceFirst('@', '')
                    .toLowerCase(),
              ),
            )
            .toList();

        final isFullscreenOverlay = chatStore.settings.fullScreen;

        final bottomBarContent = Column(
            children: [
              AnimatedScrollBorder(
                scrollController: chatStore.scrollController,
              ),
              if (chatStore.replyingToMessage != null) ...[
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 16),
                  leading: const Icon(Icons.reply),
                  title: Tooltip(
                    message: chatStore.replyingToMessage!.message,
                    preferBelow: false,
                    child: Text.rich(
                      TextSpan(
                        children: chatStore.replyingToMessage!.generateSpan(
                          context,
                          assetsStore: chatStore.assetsStore,
                          emoteScale: chatStore.settings.emoteScale,
                          badgeScale: chatStore.settings.badgeScale,
                          launchExternal: chatStore.settings.launchUrlExternal,
                          timestamp: chatStore.settings.timestampType,
                          currentChannelId: chatStore.channelId,
                        ),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.defaultTextStyle.copyWith(
                        fontSize: chatStore.settings.fontSize,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'Cancel reply',
                    onPressed: () {
                      chatStore.replyingToMessage = null;
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
              if (chatStore.settings.autocomplete &&
                  chatStore.showEmoteAutocomplete &&
                  matchingEmotes.isNotEmpty) ...[
                const Divider(),
                SizedBox(
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
              ],
              if (chatStore.settings.autocomplete &&
                  chatStore.showMentionAutocomplete &&
                  matchingChatters.isNotEmpty) ...[
                const Divider(),
                SizedBox(
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
              ],
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                child: Row(
                  children: [
                    if (!chatStore.expandChat &&
                        chatStore.settings.chatWidth < 0.3 &&
                        chatStore.settings.showVideo &&
                        context.isLandscape)
                      IconButton(
                        tooltip: 'Enter a message',
                        onPressed: () {
                          chatStore.expandChat = true;
                          chatStore.safeRequestFocus();
                        },
                        icon: const Icon(Icons.edit),
                      )
                    else
                      Expanded(
                        child: Observer(
                          builder: (context) {
                            final isDisabledDueToDelay =
                                chatStore.settings.showVideo &&
                                chatStore.settings.chatDelay > 0;
                            final isDisabled =
                                !chatStore.auth.isLoggedIn ||
                                chatStore.isSendingMessage ||
                                isDisabledDueToDelay;

                            return GestureDetector(
                              onTap: () {
                                // Show notification when trying to tap disabled input due to chat delay
                                if (isDisabledDueToDelay) {
                                  chatStore.updateNotification(
                                    'Chatting is disabled due to message delay',
                                  );
                                }
                              },
                              child: TextField(
                                textInputAction: TextInputAction.send,
                                focusNode: chatStore.textFieldFocusNode,
                                minLines: 1,
                                maxLines: 3,
                                // Disable text field when sending message, when not logged in, or when chat delay is active
                                enabled: !isDisabled,
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
                                  hintText: chatStore.auth.isLoggedIn
                                      ? chatStore.isSendingMessage
                                            ? 'Sending...'
                                            : chatStore.replyingToMessage !=
                                                  null
                                            ? 'Reply'
                                            : 'Chat'
                                      : 'Log in',
                                ),
                                controller: chatStore.textController,
                                onSubmitted: chatStore.sendMessage,
                              ),
                            );
                          },
                        ),
                      ),
                    if (chatStore.settings.showVideo &&
                        chatStore.settings.chatDelay > 0)
                      Tooltip(
                        message:
                            'Message delay: ${chatStore.settings.chatDelay.toInt()} seconds${chatStore.settings.autoSyncChatDelay ? ' (auto-synced)' : ''}',
                        preferBelow: false,
                        triggerMode: TooltipTriggerMode.tap,
                        child: Container(
                          padding: const EdgeInsets.only(left: 12),
                          width: 38,
                          child: Text(
                            '${chatStore.settings.chatDelay.toInt()}s',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontFeatures: [
                                const FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (chatStore.showSendButton &&
                        (chatStore.settings.chatWidth >= 0.3 ||
                            chatStore.expandChat ||
                            context.isPortrait))
                      Observer(
                        builder: (context) {
                          return IconButton(
                            tooltip: chatStore.isSendingMessage
                                ? 'Sending...'
                                : 'Send',
                            icon: chatStore.isSendingMessage
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
                                    !chatStore.isSendingMessage &&
                                    !(chatStore.settings.showVideo &&
                                        chatStore.settings.chatDelay > 0)
                                ? () => chatStore.sendMessage(
                                    chatStore.textController.text,
                                  )
                                : null,
                          );
                        },
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.adaptive.more_rounded),
                        tooltip: 'More',
                        onPressed: () => showModalBottomSheetWithProperFocus(
                          isScrollControlled: true,
                          context: context,
                          builder: (_) => ChatDetails(
                            chatDetailsStore: chatStore.chatDetailsStore,
                            chatStore: chatStore,
                            userLogin: chatStore.channelName,
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

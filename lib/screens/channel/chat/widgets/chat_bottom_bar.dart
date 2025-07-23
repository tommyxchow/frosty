import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/details/chat_details.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';
import 'package:frosty/widgets/cached_image.dart';

class ChatBottomBar extends StatelessWidget {
  final ChatStore chatStore;

  const ChatBottomBar({super.key, required this.chatStore});

  @override
  Widget build(BuildContext context) {
    final isEmotesEnabled = chatStore.settings.showTwitchEmotes ||
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
                FocusScope.of(context).unfocus();
                chatStore.assetsStore.showEmoteMenu =
                    !chatStore.assetsStore.showEmoteMenu;
              },
            ),
          )
        : null;

    return Observer(
      builder: (context) {
        final matchingEmotes = [
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

        return Column(
          children: [
            AnimatedScrollBorder(scrollController: chatStore.scrollController),
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
                        useReadableColors: chatStore.settings.useReadableColors,
                        launchExternal: chatStore.settings.launchUrlExternal,
                        timestamp: chatStore.settings.timestampType,
                      ),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontSize: chatStore.settings.fontSize),
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
                          height: matchingEmotes[index].height?.toDouble() ??
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
                      MediaQuery.of(context).orientation ==
                          Orientation.landscape)
                    IconButton(
                      tooltip: 'Enter a message',
                      onPressed: () {
                        chatStore.expandChat = true;
                        chatStore.textFieldFocusNode.requestFocus();
                      },
                      icon: const Icon(Icons.edit),
                    )
                  else
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.send,
                        focusNode: chatStore.textFieldFocusNode,
                        minLines: 1,
                        maxLines: 3,
                        enabled: chatStore.auth.isLoggedIn ? true : false,
                        decoration: InputDecoration(
                          prefixIcon: chatStore.settings.emoteMenuButtonOnLeft
                              ? emoteMenuButton
                              : null,
                          suffixIcon: chatStore.settings.emoteMenuButtonOnLeft
                              ? null
                              : emoteMenuButton,
                          hintMaxLines: 1,
                          hintText: chatStore.auth.isLoggedIn
                              ? 'Send a ${chatStore.replyingToMessage != null ? 'reply' : 'message'} ${chatStore.settings.chatDelay == 0 || !chatStore.settings.showVideo ? '' : '(${chatStore.settings.chatDelay.toInt()}s delay)'}'
                              : 'Log in to chat',
                        ),
                        controller: chatStore.textController,
                        onSubmitted: chatStore.sendMessage,
                        onTapOutside: (_) {
                          chatStore.textFieldFocusNode.unfocus();
                        },
                      ),
                    ),
                  if (chatStore.showSendButton &&
                      (chatStore.settings.chatWidth >= 0.3 ||
                          chatStore.expandChat ||
                          MediaQuery.of(context).orientation ==
                              Orientation.portrait))
                    IconButton(
                      tooltip: 'Send',
                      icon: const Icon(Icons.send_rounded),
                      onPressed: chatStore.auth.isLoggedIn
                          ? () => chatStore
                              .sendMessage(chatStore.textController.text)
                          : null,
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.adaptive.more_rounded),
                      tooltip: 'More',
                      onPressed: () => showModalBottomSheet(
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
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/screens/channel/chat/details/chat_details.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/widgets/button.dart';

class ChatBottomBar extends StatelessWidget {
  final ChatStore chatStore;

  const ChatBottomBar({Key? key, required this.chatStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final matchingEmotes = [
          ...chatStore.assetsStore.userEmoteToObject.values,
          ...chatStore.assetsStore.bttvEmotes,
          ...chatStore.assetsStore.ffzEmotes,
          ...chatStore.assetsStore.sevenTVEmotes
        ].where((emote) => emote.name.toLowerCase().contains(chatStore.textController.text.split(' ').last.toLowerCase())).toList();

        final matchingChatters = chatStore.chatDetailsStore.allChatters
            .where((chatter) => chatter.contains(chatStore.textController.text.split(' ').last.replaceFirst('@', '').toLowerCase()))
            .toList();

        return Column(
          children: [
            if (chatStore.settings.autocomplete && chatStore.showEmoteAutocomplete && matchingEmotes.isNotEmpty) ...[
              const Divider(
                height: 1.0,
                thickness: 1.0,
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  itemCount: matchingEmotes.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => chatStore.addEmote(matchingEmotes[index], autocompleteMode: true),
                    child: Tooltip(
                      message: matchingEmotes[index].name,
                      preferBelow: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: matchingEmotes[index].url,
                            fadeInDuration: const Duration(),
                            height: matchingEmotes[index].height?.toDouble() ?? defaultEmoteSize,
                            width: matchingEmotes[index].width?.toDouble(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (chatStore.settings.autocomplete && chatStore.showMentionAutocomplete && matchingChatters.isNotEmpty) ...[
              const Divider(
                height: 1.0,
                thickness: 1.0,
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  itemCount: matchingChatters.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Button(
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      final split = chatStore.textController.text.split(' ')
                        ..removeLast()
                        ..add('@${matchingChatters[index]} ');

                      chatStore.textController.text = split.join(' ');
                      chatStore.textController.selection = TextSelection.fromPosition(TextPosition(offset: chatStore.textController.text.length));
                    },
                    child: Text(matchingChatters[index]),
                  ),
                ),
              )
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
              child: Row(
                children: [
                  if (!chatStore.expandChat &&
                      chatStore.settings.chatWidth < 0.3 &&
                      chatStore.settings.showVideo &&
                      MediaQuery.of(context).orientation == Orientation.landscape)
                    IconButton(
                      tooltip: 'Send a message',
                      onPressed: () {
                        chatStore.expandChat = true;
                        chatStore.textFieldFocusNode.requestFocus();
                      },
                      icon: const Icon(Icons.chat),
                    )
                  else
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.send,
                        focusNode: chatStore.textFieldFocusNode,
                        minLines: 1,
                        maxLines: 5,
                        enabled: chatStore.auth.isLoggedIn ? true : false,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 10.0),
                          suffixIcon: IconButton(
                            color: chatStore.assetsStore.showEmoteMenu ? Theme.of(context).colorScheme.secondary : null,
                            tooltip: 'Emote menu',
                            icon: const Icon(Icons.emoji_emotions_outlined),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              chatStore.assetsStore.showEmoteMenu = !chatStore.assetsStore.showEmoteMenu;
                            },
                          ),
                          hintMaxLines: 1,
                          hintText: chatStore.auth.isLoggedIn
                              ? 'Send a message ${chatStore.settings.chatDelay == 0 ? '' : '(${chatStore.settings.chatDelay.toInt()}s delay)'}'
                              : 'Log in to chat',
                        ),
                        controller: chatStore.textController,
                        onSubmitted: chatStore.sendMessage,
                      ),
                    ),
                  if (chatStore.showSendButton &&
                      (chatStore.settings.chatWidth >= 0.3 || chatStore.expandChat || MediaQuery.of(context).orientation == Orientation.portrait))
                    IconButton(
                      tooltip: 'Send',
                      icon: const Icon(Icons.send),
                      onPressed: chatStore.auth.isLoggedIn ? () => chatStore.sendMessage(chatStore.textController.text) : null,
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.adaptive.more),
                      tooltip: 'More',
                      onPressed: () => showModalBottomSheet(
                        backgroundColor: Colors.transparent,
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/screens/channel/chat/details/chat_details.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';

class ChatBottomBar extends StatelessWidget {
  final ChatStore chatStore;

  const ChatBottomBar({Key? key, required this.chatStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final emotes = [
          ...chatStore.assetsStore.userEmoteToObject.values,
          ...chatStore.assetsStore.bttvEmotes,
          ...chatStore.assetsStore.ffzEmotes,
          ...chatStore.assetsStore.sevenTVEmotes
        ].where((emote) => emote.name.toLowerCase().contains(chatStore.textController.text.split(' ').last.toLowerCase())).toList();

        return Column(
          children: [
            if (chatStore.settings.emoteAutocomplete && chatStore.showAutocomplete && emotes.isNotEmpty) ...[
              const Divider(
                height: 1.0,
                thickness: 1.0,
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  itemCount: emotes.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () => chatStore.addEmote(emotes[index], autocompleteMode: true),
                    child: Tooltip(
                      message: emotes[index].name,
                      preferBelow: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Center(
                          child: CachedNetworkImage(
                            imageUrl: emotes[index].url,
                            fadeInDuration: const Duration(),
                            height: emotes[index].height?.toDouble() ?? defaultEmoteSize,
                            width: emotes[index].width?.toDouble(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.adaptive.more),
                  tooltip: 'Chat Details',
                  onPressed: () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ChatDetails(
                        chatDetails: chatStore.chatDetailsStore,
                        chatStore: chatStore,
                        userLogin: chatStore.channelName,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: TextField(
                      focusNode: chatStore.textFieldFocusNode,
                      minLines: 1,
                      maxLines: 5,
                      enabled: chatStore.auth.isLoggedIn ? true : false,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          tooltip: 'Emote Menu',
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            chatStore.assetsStore.showEmoteMenu = !chatStore.assetsStore.showEmoteMenu;
                          },
                        ),
                        hintMaxLines: 1,
                        contentPadding: const EdgeInsets.all(10.0),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        labelText: chatStore.auth.isLoggedIn ? 'Send a message' : 'Log in to chat',
                      ),
                      controller: chatStore.textController,
                      onSubmitted: chatStore.sendMessage,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Send',
                  icon: const Icon(Icons.send),
                  onPressed: chatStore.auth.isLoggedIn ? () => chatStore.sendMessage(chatStore.textController.text) : null,
                )
              ],
            ),
          ],
        );
      },
    );
  }
}

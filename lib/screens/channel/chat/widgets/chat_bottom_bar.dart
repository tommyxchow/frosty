import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/chat/details/chat_details.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';

class ChatBottomBar extends StatelessWidget {
  final ChatStore chatStore;

  const ChatBottomBar({Key? key, required this.chatStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
                userLogin: chatStore.channelName,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: TextField(
              minLines: 1,
              maxLines: 5,
              enabled: chatStore.auth.isLoggedIn ? true : false,
              onTap: () {
                chatStore.assetsStore.showEmoteMenu = false;
                Future.delayed(
                  const Duration(milliseconds: 200),
                  () => chatStore.scrollController.jumpTo(chatStore.scrollController.position.maxScrollExtent),
                );
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  tooltip: 'Emote Menu',
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    chatStore.assetsStore.showEmoteMenu = !chatStore.assetsStore.showEmoteMenu;
                  },
                ),
                isDense: true,
                contentPadding: const EdgeInsets.all(10.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: chatStore.auth.isLoggedIn ? 'Send a message' : "Log in to chat",
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
    );
  }
}

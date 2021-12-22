import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_details.dart';

class ChatBottomBar extends StatelessWidget {
  final ChatStore chatStore;

  const ChatBottomBar({Key? key, required this.chatStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.adaptive.more),
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => ChatDetails(chatStore: chatStore),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: TextField(
              minLines: 1,
              maxLines: 5,
              onTap: () => chatStore.showEmoteMenu = false,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    chatStore.showEmoteMenu = !chatStore.showEmoteMenu;
                  },
                ),
                isDense: true,
                contentPadding: const EdgeInsets.all(10.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: 'Send a message',
              ),
              controller: chatStore.textController,
              onSubmitted: chatStore.sendMessage,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => chatStore.sendMessage(chatStore.textController.text),
        )
      ],
    );
  }
}

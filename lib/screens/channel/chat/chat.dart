import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/screens/channel/chat/chat_stats.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';
import 'package:frosty/screens/channel/chat/emote_menu.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  final ChatStore chatStore;

  const Chat({Key? key, required this.chatStore}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    widget.chatStore.handleAppStateChange(state);
  }

  @override
  Widget build(BuildContext context) {
    final chatStore = widget.chatStore;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Observer(
        builder: (context) => Column(
          children: [
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Observer(
                    builder: (_) => ListView.builder(
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      itemCount: chatStore.messages.length,
                      controller: chatStore.scrollController,
                      itemBuilder: (context, index) => chatStore.renderChatMessage(chatStore.messages[index], context),
                    ),
                  ),
                  Observer(
                    builder: (_) => Visibility(
                      visible: !chatStore.autoScroll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: chatStore.resumeScroll,
                          child: const Text('Resume Scroll'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (context.read<AuthStore>().isLoggedIn)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.adaptive.more),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => ChatStats(chatStore: chatStore),
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
              ),
            if (chatStore.showEmoteMenu) ...[
              Expanded(
                child: Observer(
                  builder: (_) => EmoteMenu(
                    chatStore: chatStore,
                    emoteType: EmoteType.values[chatStore.emoteMenuIndex],
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: EmoteType.values.asMap().entries.map((e) {
                    final emotes = chatStore.emoteToObject.values.toList().where((emote) => emote.type == EmoteType.values[e.key]).toList();

                    return Observer(
                      builder: (_) => TextButton(
                        style: e.key == chatStore.emoteMenuIndex ? null : TextButton.styleFrom(primary: Colors.grey),
                        onPressed: emotes.isEmpty ? null : () => chatStore.emoteMenuIndex = e.key,
                        child: Text(chatStore.emoteMenuTitle(e.value)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    widget.chatStore.dispose();
    super.dispose();
  }
}

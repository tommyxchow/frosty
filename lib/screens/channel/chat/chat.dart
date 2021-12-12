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

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.chatStore.getAssets(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Observer(
              builder: (context) {
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          Observer(
                            builder: (_) {
                              return ListView.builder(
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: false,
                                itemCount: widget.chatStore.messages.length,
                                controller: widget.chatStore.scrollController,
                                itemBuilder: (context, index) {
                                  return widget.chatStore.renderChatMessage(widget.chatStore.messages[index], context);
                                },
                              );
                            },
                          ),
                          Observer(
                            builder: (_) {
                              return Visibility(
                                visible: !widget.chatStore.autoScroll,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: widget.chatStore.resumeScroll,
                                    child: const Text('Resume Scroll'),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.adaptive.more),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return ChatStats(
                                  chatStore: widget.chatStore,
                                );
                              },
                            );
                          },
                        ),
                        if (context.read<AuthStore>().isLoggedIn) ...[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                              child: TextField(
                                minLines: 1,
                                maxLines: 5,
                                onTap: () => widget.chatStore.showEmoteMenu = false,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.emoji_emotions_outlined),
                                    onPressed: () {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      widget.chatStore.showEmoteMenu = !widget.chatStore.showEmoteMenu;
                                    },
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(10.0),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  hintText: 'Send a message',
                                ),
                                controller: widget.chatStore.textController,
                                onSubmitted: (string) => widget.chatStore.sendMessage(string),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () => widget.chatStore.sendMessage(widget.chatStore.textController.text),
                          )
                        ],
                      ],
                    ),
                    if (widget.chatStore.showEmoteMenu) ...[
                      IndexedStack(
                        index: widget.chatStore.emoteMenuIndex,
                        children: EmoteType.values.map((type) => EmoteMenu(chatStore: widget.chatStore, emoteType: type)).toList(),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children: EmoteType.values
                                .asMap()
                                .entries
                                .map((e) => TextButton(
                                      style: e.key == widget.chatStore.emoteMenuIndex ? null : TextButton.styleFrom(primary: Colors.grey),
                                      onPressed: () => widget.chatStore.emoteMenuIndex = e.key,
                                      child: Text(widget.chatStore.emoteMenuTitle(e.value)),
                                    ))
                                .toList()),
                      )
                    ]
                  ],
                );
              },
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.chatStore.dispose();
    super.dispose();
  }
}

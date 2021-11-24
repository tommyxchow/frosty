import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/channel/chat/chat_stats.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';
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
            child: Column(
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
                      icon: const Icon(Icons.stacked_bar_chart),
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
                    if (context.read<AuthStore>().isLoggedIn)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              hintText: 'Send a message',
                            ),
                            controller: widget.chatStore.textController,
                            onSubmitted: (string) => widget.chatStore.sendMessage(string),
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
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

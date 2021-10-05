import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/chat_store.dart';

class Chat extends StatefulWidget {
  final AuthStore auth;
  final Channel channelInfo;

  const Chat({Key? key, required this.auth, required this.channelInfo}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late final ChatStore chatStore = ChatStore(auth: widget.auth, channelInfo: widget.channelInfo);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: chatStore.getAssets(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder(
            stream: chatStore.channel.stream,
            builder: (context, snapshot) {
              chatStore.handleWebsocketData(snapshot.data);
              return Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: chatStore.messages.length,
                    controller: chatStore.scrollController,
                    padding: const EdgeInsets.all(5.0),
                    itemBuilder: (context, index) {
                      return chatStore.parseIrcMessage(chatStore.messages[index]);
                    },
                  ),
                  Observer(
                    builder: (_) {
                      return Visibility(
                        visible: !chatStore.autoScroll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => chatStore.resumeScroll(),
                            child: const Text('Resume Scroll'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
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
    chatStore.channel.sink.close();
    super.dispose();
  }
}

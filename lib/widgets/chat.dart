import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/chat_store.dart';

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
          return Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Observer(
                builder: (_) {
                  if (widget.chatStore.autoScroll) {
                    SchedulerBinding.instance?.addPostFrameCallback((_) {
                      widget.chatStore.scrollController.jumpTo(widget.chatStore.scrollController.position.maxScrollExtent);
                    });
                  }
                  return ListView.builder(
                    itemCount: widget.chatStore.messages.length,
                    controller: widget.chatStore.scrollController,
                    padding: const EdgeInsets.all(5.0),
                    itemBuilder: (context, index) {
                      return widget.chatStore.renderChatMessage(widget.chatStore.messages[index]);
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
                        onPressed: () => widget.chatStore.resumeScroll(),
                        child: const Text('Resume Scroll'),
                      ),
                    ),
                  );
                },
              ),
            ],
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
    widget.chatStore.channel.sink.close();
    widget.chatStore.scrollController.dispose();
    super.dispose();
  }
}

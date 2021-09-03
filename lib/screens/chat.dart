import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/providers/chat_provider.dart';
import 'package:frosty/widgets/chat_message.dart';
import 'package:provider/provider.dart';

// TODO: Remove test token dependency.
// TODO: Use padding/margin for badge spacing.

class Chat extends StatefulWidget {
  final Channel channelInfo;

  const Chat({Key? key, required this.channelInfo}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // Here, we have a FutureBuilder that will wait for the emotes to be fetched.
  // Once the emotes are acquired, the chat (stream) builder will start.
  @override
  Widget build(BuildContext context) {
    print('build');
    final viewModel = context.read<ChatProvider>();
    return Container(
      child: FutureBuilder(
        future: viewModel.getEmotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
              stream: viewModel.channel.stream,
              builder: (context, snapshot) {
                for (final message in snapshot.data.toString().split('\r\n')) {
                  // print(message);
                  if (message.startsWith('@')) {
                    viewModel.messages.add(const SizedBox(height: 10));
                    viewModel.messages.add(ChatMessage(
                      children: viewModel.parseIrcMessage(message),
                    ));
                  }
                  SchedulerBinding.instance?.addPostFrameCallback((_) {
                    viewModel.scrollController.jumpTo(viewModel.scrollController.position.maxScrollExtent);
                  });
                }
                return ListView.builder(
                  itemCount: viewModel.messages.length,
                  controller: viewModel.scrollController,
                  padding: EdgeInsets.all(5.0),
                  itemBuilder: (context, index) {
                    return viewModel.messages[index];
                  },
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

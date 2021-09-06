import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/providers/chat_provider.dart';
import 'package:frosty/widgets/chat_message.dart';
import 'package:provider/provider.dart';

// TODO: Remove test token dependency.
// TODO: Use padding/margin for badge spacing.

class Chat extends StatelessWidget {
  final Channel channelInfo;

  const Chat({Key? key, required this.channelInfo}) : super(key: key);

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
                  if (viewModel.autoScroll) {
                    SchedulerBinding.instance?.addPostFrameCallback((_) {
                      viewModel.scrollController.jumpTo(viewModel.scrollController.position.maxScrollExtent);
                    });
                  }
                }
                return Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    ListView.builder(
                      itemCount: viewModel.messages.length,
                      controller: viewModel.scrollController,
                      padding: EdgeInsets.all(5.0),
                      itemBuilder: (context, index) {
                        return viewModel.messages[index];
                      },
                    ),
                    Consumer<ChatProvider>(
                      builder: (context, viewModel, child) {
                        if (!viewModel.autoScroll)
                          return ElevatedButton(
                            onPressed: () {
                              viewModel.autoScroll = true;
                              viewModel.scrollController.jumpTo(viewModel.scrollController.position.maxScrollExtent);
                              SchedulerBinding.instance?.addPostFrameCallback((_) {
                                viewModel.scrollController.jumpTo(viewModel.scrollController.position.maxScrollExtent);
                              });
                            },
                            child: Text('Resume Scroll'),
                          );
                        return const Text('');
                      },
                    ),
                  ],
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

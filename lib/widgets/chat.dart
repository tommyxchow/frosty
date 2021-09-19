import 'package:flutter/material.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class Chat extends StatelessWidget {
  final Channel channelInfo;

  const Chat({Key? key, required this.channelInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('build');
    final viewModel = context.read<ChatProvider>();
    return FutureBuilder(
      future: viewModel.getEmotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder(
            stream: viewModel.channel.stream,
            builder: (context, snapshot) {
              viewModel.handleWebsocketData(snapshot.data);
              if (viewModel.messages.isNotEmpty) {
                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(5.0),
                  children: viewModel.messages.reversed.toList(),
                );
              }
              return const SizedBox();
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

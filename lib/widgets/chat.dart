import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/stores/chat_store.dart';

class Chat extends StatefulWidget {
  final Channel channelInfo;

  const Chat({Key? key, required this.channelInfo}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final viewModel = ChatStore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: viewModel.start(widget.channelInfo),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder(
            stream: viewModel.channel.stream,
            builder: (context, snapshot) {
              viewModel.handleWebsocketData(snapshot.data);
              return Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  ListView.builder(
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    physics: const ClampingScrollPhysics(),
                    itemCount: viewModel.messages.length,
                    controller: viewModel.scrollController,
                    padding: const EdgeInsets.all(5.0),
                    itemBuilder: (context, index) {
                      return viewModel.parseIrcMessage(viewModel.messages[index]);
                    },
                  ),
                  Observer(
                    builder: (_) {
                      return Visibility(
                        visible: !viewModel.autoScroll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => viewModel.resumeScroll(),
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
    viewModel.channel.sink.close();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/chat_store.dart';
import 'package:frosty/stores/settings_store.dart';
import 'package:frosty/widgets/chat.dart';
import 'package:frosty/widgets/video.dart';
import 'package:provider/provider.dart';

class VideoChat extends StatelessWidget {
  final String userLogin;

  const VideoChat({Key? key, required this.userLogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Visibility(
              visible: context.read<SettingsStore>().videoEnabled,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(channelName: userLogin),
              ),
            ),
            Expanded(
              child: Chat(chatStore: ChatStore(auth: context.read<AuthStore>(), channelName: userLogin)),
            ),
            const TextField(),
          ],
        ),
      ),
    );
  }
}

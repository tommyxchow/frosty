import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/settings_store.dart';
import 'package:frosty/widgets/chat.dart';
import 'package:frosty/widgets/video.dart';
import 'package:provider/provider.dart';

class VideoChat extends StatelessWidget {
  final Channel channelInfo;

  const VideoChat({Key? key, required this.channelInfo}) : super(key: key);

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
                child: Video(channelName: channelInfo.userLogin),
              ),
            ),
            Expanded(
              child: Chat(auth: context.read<AuthStore>(), channelInfo: channelInfo),
            ),
            const TextField(),
          ],
        ),
      ),
    );
  }
}

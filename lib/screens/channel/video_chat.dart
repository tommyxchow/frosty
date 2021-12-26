import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';
import 'package:frosty/screens/channel/video/video.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:provider/provider.dart';

class VideoChat extends StatelessWidget {
  final String title;
  final String userName;
  final String userLogin;

  const VideoChat({
    Key? key,
    required this.title,
    required this.userName,
    required this.userLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final video = Video(
      key: GlobalKey(),
      userLogin: userLogin,
      videoStore: VideoStore(
        userLogin: userLogin,
        authStore: context.read<AuthStore>(),
      ),
    );

    final chat = Chat(
      key: GlobalKey(),
      chatStore: ChatStore(
        auth: context.read<AuthStore>(),
        settings: context.read<SettingsStore>(),
        channelName: userLogin,
      ),
    );

    final appBar = AppBar(
      title: Text(
        userName,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (context) {
              return Settings(settingsStore: context.read<SettingsStore>());
            },
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
              return Observer(
                builder: (context) {
                  if (context.read<SettingsStore>().videoEnabled) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: Observer(
                        builder: (context) => context.read<SettingsStore>().fullScreen
                            ? Stack(
                                children: [
                                  Visibility(
                                    visible: false,
                                    maintainState: true,
                                    child: chat,
                                  ),
                                  Center(child: video),
                                ],
                              )
                            : Row(
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: video,
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: chat,
                                  ),
                                ],
                              ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      appBar,
                      Expanded(child: chat),
                    ],
                  );
                },
              );
            }

            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
            return Column(
              children: [
                Observer(
                  builder: (context) {
                    if (context.read<SettingsStore>().videoEnabled) {
                      return video;
                    }
                    return appBar;
                  },
                ),
                Expanded(
                  child: chat,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

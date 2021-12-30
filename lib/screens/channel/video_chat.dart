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
    final authStore = context.read<AuthStore>();
    final settingsStore = context.read<SettingsStore>();

    final video = Video(
      key: GlobalKey(),
      userLogin: userLogin,
      videoStore: VideoStore(
        userLogin: userLogin,
        authStore: authStore,
        settingsStore: settingsStore,
      ),
    );

    final chat = Chat(
      key: GlobalKey(),
      chatStore: ChatStore(
        auth: authStore,
        settings: settingsStore,
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
              return Settings(settingsStore: settingsStore);
            },
          ),
        ),
      ],
    );

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          if (settingsStore.fullScreen) SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: Observer(
                builder: (context) {
                  if (settingsStore.videoEnabled) {
                    return Observer(
                      builder: (context) => settingsStore.fullScreen
                          ? WillPopScope(
                              onWillPop: () async => false,
                              child: Stack(
                                children: [
                                  Visibility(
                                    visible: false,
                                    maintainState: true,
                                    child: chat,
                                  ),
                                  Center(child: video),
                                ],
                              ),
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
                    );
                  }
                  return Column(
                    children: [
                      appBar,
                      Expanded(child: chat),
                    ],
                  );
                },
              ),
            ),
          );
        }

        settingsStore.fullScreen = false;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Observer(
                  builder: (context) {
                    if (settingsStore.videoEnabled) {
                      return video;
                    }
                    return appBar;
                  },
                ),
                Expanded(
                  child: chat,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

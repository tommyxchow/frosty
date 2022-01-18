import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/screens/channel/stores/video_store.dart';
import 'package:frosty/screens/channel/video/video.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:provider/provider.dart';

class VideoChat extends StatefulWidget {
  final ChatStore chatStore;

  const VideoChat({Key? key, required this.chatStore}) : super(key: key);

  @override
  _VideoChatState createState() => _VideoChatState();
}

class _VideoChatState extends State<VideoChat> {
  @override
  Widget build(BuildContext context) {
    final chatStore = widget.chatStore;
    final settingsStore = chatStore.settings;

    final video = Video(
      key: GlobalKey(),
      userLogin: chatStore.channelName,
      videoStore: VideoStore(
        twitchApi: context.read<TwitchApi>(),
        userLogin: chatStore.channelName,
        authStore: chatStore.auth,
        settingsStore: chatStore.settings,
      ),
    );

    final chat = Chat(
      key: GlobalKey(),
      chatStore: chatStore,
    );

    final appBar = AppBar(
      title: Text(
        chatStore.displayName,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings),
          onPressed: () => showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Settings(settingsStore: settingsStore),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            return Observer(
              builder: (context) => ColoredBox(
                color: settingsStore.showVideo ? Colors.black : Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  bottom: false,
                  child: settingsStore.showVideo
                      ? settingsStore.fullScreen
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
                                  child: ColoredBox(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    child: chat,
                                  ),
                                ),
                              ],
                            )
                      : Column(
                          children: [
                            appBar,
                            Expanded(child: chat),
                          ],
                        ),
                ),
              ),
            );
          }

          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
          );
          return SafeArea(
            child: Column(
              children: [
                Observer(
                  builder: (_) {
                    if (settingsStore.showVideo) {
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.chatStore.dispose();
    super.dispose();
  }
}

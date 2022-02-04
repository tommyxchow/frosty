import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/api/bttv_api.dart';
import 'package:frosty/api/ffz_api.dart';
import 'package:frosty/api/seventv_api.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/stores/chat_assets_store.dart';
import 'package:frosty/screens/channel/stores/chat_details_store.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/screens/channel/stores/video_store.dart';
import 'package:frosty/screens/channel/video/video.dart';
import 'package:frosty/screens/channel/video/video_overlay.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:provider/provider.dart';

class VideoChat extends StatefulWidget {
  final String userId;
  final String userName;
  final String userLogin;

  const VideoChat({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userLogin,
  }) : super(key: key);

  @override
  _VideoChatState createState() => _VideoChatState();
}

class _VideoChatState extends State<VideoChat> {
  final _videoKey = GlobalKey();
  final _chatKey = GlobalKey();

  late final ChatStore _chatStore = ChatStore(
    channelName: widget.userLogin,
    channelId: widget.userId,
    displayName: widget.userName,
    auth: context.read<AuthStore>(),
    settings: context.read<SettingsStore>(),
    chatDetailsStore: ChatDetailsStore(
      twitchApi: context.read<TwitchApi>(),
    ),
    assetsStore: ChatAssetsStore(
      twitchApi: context.read<TwitchApi>(),
      ffzApi: context.read<FFZApi>(),
      bttvApi: context.read<BTTVApi>(),
      sevenTVApi: context.read<SevenTVApi>(),
    ),
  );

  late final VideoStore _videoStore = VideoStore(
    userLogin: widget.userLogin,
    twitchApi: context.read<TwitchApi>(),
    authStore: context.read<AuthStore>(),
    settingsStore: context.read<SettingsStore>(),
  );

  @override
  Widget build(BuildContext context) {
    final settingsStore = _chatStore.settings;

    final player = Video(
      key: _videoKey,
      videoStore: _videoStore,
    );

    final video = GestureDetector(
      onLongPress: _videoStore.handleToggleOverlay,
      onTap: () {
        if (_chatStore.assetsStore.showEmoteMenu) {
          _chatStore.assetsStore.showEmoteMenu = false;
        } else {
          if (_chatStore.textFieldFocusNode.hasFocus) {
            _chatStore.textFieldFocusNode.unfocus();
          } else {
            _videoStore.handleVideoTap();
          }
        }
      },
      child: Observer(
        builder: (context) {
          if (_videoStore.settingsStore.showOverlay) {
            return Stack(
              children: [
                player,
                Observer(
                  builder: (_) {
                    if (_videoStore.paused) return VideoOverlay(videoStore: _videoStore);
                    return Observer(
                      builder: (_) => AnimatedOpacity(
                        opacity: _videoStore.overlayVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: ColoredBox(
                          color: const Color.fromRGBO(0, 0, 0, 0.5),
                          child: IgnorePointer(
                            ignoring: !_videoStore.overlayVisible,
                            child: VideoOverlay(videoStore: _videoStore),
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            );
          }
          return player;
        },
      ),
    );

    final chat = Chat(
      key: _chatKey,
      chatStore: _chatStore,
    );

    final appBar = AppBar(
      title: Text(
        regexEnglish.hasMatch(_chatStore.displayName) ? _chatStore.displayName : _chatStore.displayName + ' (${_chatStore.channelName})',
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
            // Add a post-frame callback to scroll to bottom when rotating.
            SchedulerBinding.instance?.addPostFrameCallback((_) {
              if (_chatStore.scrollController.hasClients) _chatStore.scrollController.jumpTo(_chatStore.scrollController.position.maxScrollExtent);
            });

            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

            return Observer(
              builder: (context) => ColoredBox(
                color: settingsStore.showVideo ? Colors.black : Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  bottom: false,
                  child: settingsStore.showVideo
                      ? settingsStore.fullScreen
                          ? Stack(
                              children: [
                                Visibility(
                                  visible: false,
                                  maintainState: true,
                                  child: chat,
                                ),
                                video,
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
            overlays: SystemUiOverlay.values,
          );
          return SafeArea(
            child: Column(
              children: [
                Observer(
                  builder: (_) {
                    if (settingsStore.showVideo) {
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: video,
                      );
                    }
                    return appBar;
                  },
                ),
                Expanded(child: chat),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _chatStore.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.dispose();
  }
}

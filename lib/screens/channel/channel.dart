import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_assets_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/video/video.dart';
import 'package:frosty/screens/channel/video/video_overlay.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/modal.dart';
import 'package:provider/provider.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'package:simple_pip_mode/pip_widget.dart';

/// Creates a widget that shows the video stream (if live) and chat of the given user.
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
  State<VideoChat> createState() => _VideoChatState();
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
      channelName: widget.userLogin,
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

    void showSettings() => showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (context) => FrostyModal(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Settings(settingsStore: settingsStore),
            ),
          ),
        );

    final appBar = AppBar(
      title: Text(
        regexEnglish.hasMatch(_chatStore.displayName) ? _chatStore.displayName : '${_chatStore.displayName} (${_chatStore.channelName})',
        style: const TextStyle(fontSize: 20),
      ),
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings),
          onPressed: showSettings,
        ),
      ],
    );

    final player = GestureDetector(
      onLongPress: _videoStore.handleToggleOverlay,
      child: Video(
        key: _videoKey,
        videoStore: _videoStore,
      ),
    );

    final videoOverlay = VideoOverlay(
      videoStore: _videoStore,
      onSettingsPressed: showSettings,
    );

    final overlay = GestureDetector(
      onLongPress: _videoStore.handleToggleOverlay,
      onDoubleTap: MediaQuery.of(context).orientation == Orientation.landscape ? () => settingsStore.fullScreen = !settingsStore.fullScreen : null,
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
        builder: (_) {
          if (_videoStore.paused || _videoStore.streamInfo == null) return videoOverlay;

          return AnimatedOpacity(
            opacity: _videoStore.overlayVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.25, 0.75, 1.0],
                  colors: [
                    Colors.black.withOpacity(settingsStore.overlayOpacity),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(settingsStore.overlayOpacity),
                  ],
                ),
              ),
              child: IgnorePointer(
                ignoring: !_videoStore.overlayVisible,
                child: videoOverlay,
              ),
            ),
          );
        },
      ),
    );

    final video = Observer(
      builder: (context) {
        if (!_videoStore.settingsStore.showOverlay) return player;

        return Stack(
          children: [
            player,
            overlay,
          ],
        );
      },
    );

    final chat = Chat(
      key: _chatKey,
      chatStore: _chatStore,
    );

    final videoChat = Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Observer(
            builder: (_) {
              if (orientation == Orientation.landscape && !settingsStore.landscapeForceVerticalChat) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

                final landscapeChat = AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _chatStore.expandChat ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width * _chatStore.settings.chatWidth,
                  curve: Curves.ease,
                  color: _chatStore.settings.fullScreen
                      ? Colors.black.withOpacity(_chatStore.settings.fullScreenChatOverlayOpacity)
                      : Theme.of(context).scaffoldBackgroundColor,
                  child: chat,
                );

                final overlayChat = Visibility(
                  visible: settingsStore.fullScreenChatOverlay,
                  maintainState: true,
                  child: Theme(
                    data: darkTheme,
                    child: DefaultTextStyle(
                      style: DefaultTextStyle.of(context).style.copyWith(color: Colors.white),
                      child: landscapeChat,
                    ),
                  ),
                );

                return ColoredBox(
                  color: settingsStore.showVideo ? Colors.black : Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(
                    bottom: false,
                    left:
                        (settingsStore.landscapeCutout == LandscapeCutoutType.both || settingsStore.landscapeCutout == LandscapeCutoutType.left) ? false : true,
                    right: (settingsStore.landscapeCutout == LandscapeCutoutType.both || settingsStore.landscapeCutout == LandscapeCutoutType.right)
                        ? false
                        : true,
                    child: settingsStore.showVideo
                        ? settingsStore.fullScreen
                            ? Stack(
                                children: [
                                  player,
                                  if (settingsStore.showOverlay)
                                    Row(
                                      children: settingsStore.landscapeChatLeftSide
                                          ? [overlayChat, Expanded(child: overlay)]
                                          : [Expanded(child: overlay), overlayChat],
                                    )
                                ],
                              )
                            : Row(
                                children:
                                    settingsStore.landscapeChatLeftSide ? [landscapeChat, Expanded(child: video)] : [Expanded(child: video), landscapeChat],
                              )
                        : Column(
                            children: [appBar, Expanded(child: chat)],
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
                    if (!settingsStore.showVideo) appBar else AspectRatio(aspectRatio: 16 / 9, child: video),
                    Expanded(child: chat),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    // If on Android, use PiPSwitcher to enable PiP functionality.
    if (Platform.isAndroid) {
      return PipWidget(
        pipLayout: PipActionsLayout.media_only_pause,
        onPipAction: (_) => _videoStore.handlePausePlay(),
        pipChild: player,
        child: videoChat,
      );
    }

    return videoChat;
  }

  @override
  void dispose() {
    _chatStore.dispose();

    _videoStore.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    SystemChrome.setPreferredOrientations([]);

    super.dispose();
  }
}

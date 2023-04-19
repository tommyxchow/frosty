import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/video/video_bar.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/widgets/bottom_sheet.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:intl/intl.dart';

/// Creates a widget containing controls which enable interactions with an underlying [Video] widget.
class VideoOverlay extends StatelessWidget {
  final VideoStore videoStore;
  final ChatStore chatStore;

  const VideoOverlay({
    Key? key,
    required this.videoStore,
    required this.chatStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    final backButton = IconButton(
      tooltip: 'Back',
      icon: Icon(
        Icons.adaptive.arrow_back_rounded,
        color: Colors.white,
      ),
      onPressed: Navigator.of(context).pop,
    );

    final chatOverlayButton = Observer(
      builder: (_) => IconButton(
        tooltip: videoStore.settingsStore.fullScreenChatOverlay ? 'Hide chat overlay' : 'Show chat overlay',
        onPressed: () =>
            videoStore.settingsStore.fullScreenChatOverlay = !videoStore.settingsStore.fullScreenChatOverlay,
        icon: videoStore.settingsStore.fullScreenChatOverlay
            ? const Icon(Icons.chat_rounded)
            : const Icon(Icons.chat_outlined),
        color: Colors.white,
      ),
    );

    final refreshButton = Tooltip(
      message: 'Refresh',
      preferBelow: false,
      child: IconButton(
        icon: const Icon(
          Icons.refresh_rounded,
          color: Colors.white,
        ),
        onPressed: videoStore.handleRefresh,
      ),
    );

    final fullScreenButton = Tooltip(
      message: videoStore.settingsStore.fullScreen ? 'Exit fullscreen mode' : 'Enter fullscreen mode',
      preferBelow: false,
      child: IconButton(
        icon: Icon(
          videoStore.settingsStore.fullScreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
          color: Colors.white,
        ),
        onPressed: () => videoStore.settingsStore.fullScreen = !videoStore.settingsStore.fullScreen,
      ),
    );

    final rotateButton = Tooltip(
      message: orientation == Orientation.portrait ? 'Enter landscape mode' : 'Exit landscape mode',
      preferBelow: false,
      child: IconButton(
        icon: const Icon(
          Icons.screen_rotation_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          if (orientation == Orientation.portrait) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          } else {
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
            SystemChrome.setPreferredOrientations([]);
          }
        },
      ),
    );

    final streamInfo = videoStore.streamInfo;
    if (streamInfo == null) {
      return Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              backButton,
              const Spacer(),
              if (videoStore.settingsStore.fullScreen && orientation == Orientation.landscape) chatOverlayButton,
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                refreshButton,
                if (!videoStore.isIPad) rotateButton,
                if (orientation == Orientation.landscape) fullScreenButton,
              ],
            ),
          ),
        ],
      );
    }

    return Observer(
      builder: (context) {
        final qualities = videoStore.streamLinks!.keys
            .map(
              (quality) => ListTile(
                title: Text(quality),
                trailing: videoStore.selectedQuality == quality ? const Icon(Icons.check_rounded) : null,
                onTap: () {
                  videoStore.handleQualityChange(quality);
                  Navigator.of(context).pop();
                },
              ),
            )
            .toList();

        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                backButton,
                if (orientation == Orientation.landscape)
                  Expanded(
                    child: VideoBar(
                      streamInfo: streamInfo,
                      titleTextColor: Colors.white,
                      subtitleTextColor: Colors.white,
                      subtitleTextWeight: FontWeight.w500,
                    ),
                  ),
                const Spacer(),
                if (videoStore.settingsStore.useNativePlayer && videoStore.streamLinks != null)
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => FrostyBottomSheet(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Select quality',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            MediaQuery.of(context).orientation == Orientation.landscape
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: ListView(
                                      children: qualities,
                                    ),
                                  )
                                : Column(
                                    children: qualities,
                                  )
                          ],
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                    ),
                  ),
                if (videoStore.settingsStore.fullScreen && orientation == Orientation.landscape) chatOverlayButton,
              ],
            ),
            Center(
              child: Tooltip(
                message: videoStore.paused ? 'Play' : 'Pause',
                preferBelow: false,
                child: IconButton(
                  iconSize: 50.0,
                  icon: Icon(
                    videoStore.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                  ),
                  onPressed: videoStore.handlePausePlay,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 12.0),
                      child: Row(
                        children: [
                          Tooltip(
                            message: 'Stream uptime',
                            preferBelow: false,
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 10,
                                  ),
                                ),
                                const SizedBox(width: 3.0),
                                Uptime(
                                  startTime: streamInfo.startedAt,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Tooltip(
                            message: 'Viewer count',
                            preferBelow: false,
                            child: GestureDetector(
                              onTap: () => showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                context: context,
                                builder: (context) => FrostyBottomSheet(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.8,
                                    child: GestureDetector(
                                      onTap: FocusScope.of(context).unfocus,
                                      child: ChattersList(
                                        chatDetailsStore: chatStore.chatDetailsStore,
                                        chatStore: chatStore,
                                        userLogin: streamInfo.userLogin,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    NumberFormat().format(videoStore.streamInfo?.viewerCount),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Enter picture-in-picture',
                    preferBelow: false,
                    child: IconButton(
                      icon: const Icon(
                        Icons.picture_in_picture_alt_rounded,
                        color: Colors.white,
                      ),
                      onPressed: videoStore.requestPictureInPicture,
                    ),
                  ),
                  refreshButton,
                  if (!videoStore.isIPad) rotateButton,
                  if (orientation == Orientation.landscape) fullScreenButton,
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

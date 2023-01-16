import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/channel/video/video_bar.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';

/// Creates a widget containing controls which enable interactions with an underlying [Video] widget.
class VideoOverlay extends StatelessWidget {
  final VideoStore videoStore;

  const VideoOverlay({
    Key? key,
    required this.videoStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    final backButton = IconButton(
      tooltip: 'Back',
      icon: const HeroIcon(
        HeroIcons.chevronLeft,
        color: Colors.white,
        style: HeroIconStyle.solid,
      ),
      onPressed: Navigator.of(context).pop,
    );

    final chatOverlayButton = Observer(
      builder: (_) => IconButton(
        tooltip: videoStore.settingsStore.fullScreenChatOverlay ? 'Hide chat overlay' : 'Show chat overlay',
        onPressed: () =>
            videoStore.settingsStore.fullScreenChatOverlay = !videoStore.settingsStore.fullScreenChatOverlay,
        icon: HeroIcon(HeroIcons.chatBubbleOvalLeftEllipsis,
            style: videoStore.settingsStore.fullScreenChatOverlay ? HeroIconStyle.solid : null),
        color: Colors.white,
      ),
    );

    final refreshButton = Tooltip(
      message: 'Refresh',
      preferBelow: false,
      child: IconButton(
        icon: const HeroIcon(
          HeroIcons.arrowPath,
          color: Colors.white,
          style: HeroIconStyle.solid,
        ),
        onPressed: videoStore.handleRefresh,
      ),
    );

    final fullScreenButton = Tooltip(
      message: videoStore.settingsStore.fullScreen ? 'Exit fullscreen mode' : 'Enter fullscreen mode',
      preferBelow: false,
      child: IconButton(
        icon: videoStore.settingsStore.fullScreen
            ? const HeroIcon(
                HeroIcons.arrowsPointingIn,
                color: Colors.white,
                style: HeroIconStyle.solid,
              )
            : const HeroIcon(
                HeroIcons.arrowsPointingOut,
                color: Colors.white,
                style: HeroIconStyle.solid,
              ),
        onPressed: () => videoStore.settingsStore.fullScreen = !videoStore.settingsStore.fullScreen,
      ),
    );

    final rotateButton = Tooltip(
      message: orientation == Orientation.portrait ? 'Enter landscape mode' : 'Exit landscape mode',
      preferBelow: false,
      child: IconButton(
        icon: const Icon(
          Icons.screen_rotation,
          color: Colors.white,
        ),
        onPressed: () {
          if (orientation == Orientation.portrait) {
            if (Platform.isIOS) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeRight,
              ]);
              SystemChrome.setPreferredOrientations([]);
            } else {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeRight,
                DeviceOrientation.landscapeLeft,
              ]);
            }
          } else {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
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
        return Stack(
          children: [
            ColoredBox(
              color: orientation == Orientation.landscape ? lightGray : Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  backButton,
                  if (orientation == Orientation.landscape) Expanded(child: VideoBar(streamInfo: streamInfo)),
                  if (videoStore.settingsStore.fullScreen && orientation == Orientation.landscape) chatOverlayButton,
                ],
              ),
            ),
            Center(
              child: Tooltip(
                message: videoStore.paused ? 'Play' : 'Pause',
                preferBelow: false,
                child: IconButton(
                  iconSize: 50.0,
                  icon: videoStore.paused
                      ? const HeroIcon(
                          HeroIcons.play,
                          color: Colors.white,
                          style: HeroIconStyle.solid,
                        )
                      : const HeroIcon(
                          HeroIcons.pause,
                          color: Colors.white,
                          style: HeroIconStyle.solid,
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
                      padding: const EdgeInsets.all(12.0),
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
                                const SizedBox(width: 5),
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
                            child: Row(
                              children: [
                                const HeroIcon(
                                  HeroIcons.users,
                                  size: 14,
                                  color: Colors.white,
                                  style: HeroIconStyle.solid,
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

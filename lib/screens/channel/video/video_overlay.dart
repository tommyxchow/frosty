import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:intl/intl.dart';

/// Creates a widget containing controls which enable interactions with an underlying [Video] widget.
class VideoOverlay extends StatelessWidget {
  final VideoStore videoStore;
  final void Function() onSettingsPressed;

  const VideoOverlay({
    Key? key,
    required this.videoStore,
    required this.onSettingsPressed,
  }) : super(key: key);

  Future<void> _showSleepTimerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Sleep Timer',
        content: Observer(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer),
                  Text(' ${videoStore.timeRemaining.toString().split('.')[0]}'),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Cancel sleep timer',
                    onPressed: videoStore.sleepTimer != null && videoStore.sleepTimer!.isActive ? videoStore.cancelSleepTimer : null,
                    icon: const Icon(Icons.cancel),
                  ),
                ],
              ),
              Row(
                children: [
                  DropdownButton(
                    value: videoStore.sleepHours,
                    items: List.generate(24, (index) => index).map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                    onChanged: (int? hours) => videoStore.sleepHours = hours!,
                    menuMaxHeight: 200,
                  ),
                  const SizedBox(width: 10.0),
                  const Text('Hours'),
                ],
              ),
              Row(
                children: [
                  DropdownButton(
                    value: videoStore.sleepMinutes,
                    items: List.generate(60, (index) => index).map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                    onChanged: (int? minutes) => videoStore.sleepMinutes = minutes!,
                    menuMaxHeight: 200,
                  ),
                  const SizedBox(width: 10.0),
                  const Text('Minutes'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Observer(
            builder: (context) => Button(
              onPressed: videoStore.sleepHours == 0 && videoStore.sleepMinutes == 0
                  ? null
                  : () => videoStore.updateSleepTimer(
                        onTimerFinished: () => navigatorKey.currentState?.popUntil((route) => route.isFirst),
                      ),
              child: const Text('Set Timer'),
            ),
          ),
          Button(
            onPressed: Navigator.of(context).pop,
            fill: true,
            color: Colors.red.shade700,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    final backButton = IconButton(
      tooltip: 'Back',
      icon: Icon(
        Icons.adaptive.arrow_back,
        color: Colors.white,
      ),
      onPressed: Navigator.of(context).pop,
    );

    final settingsButton = IconButton(
      tooltip: 'Settings',
      icon: const Icon(
        Icons.settings,
        color: Colors.white,
      ),
      onPressed: onSettingsPressed,
    );

    final chatOverlayButton = Observer(
      builder: (_) => IconButton(
        tooltip: videoStore.settingsStore.fullScreenChatOverlay ? 'Hide chat overlay' : 'Show chat overlay',
        onPressed: () => videoStore.settingsStore.fullScreenChatOverlay = !videoStore.settingsStore.fullScreenChatOverlay,
        icon: videoStore.settingsStore.fullScreenChatOverlay ? const Icon(Icons.chat_bubble_outline) : const Icon(Icons.chat_bubble),
        color: Colors.white,
      ),
    );

    final refreshButton = IconButton(
      tooltip: 'Refresh',
      icon: const Icon(
        Icons.refresh,
        color: Colors.white,
      ),
      onPressed: videoStore.handleRefresh,
    );

    final fullScreenButton = IconButton(
      tooltip: videoStore.settingsStore.fullScreen ? 'Exit fullscreen mode' : 'Enter fullscreen mode',
      icon: videoStore.settingsStore.fullScreen
          ? const Icon(
              Icons.fullscreen_exit,
              color: Colors.white,
            )
          : const Icon(
              Icons.fullscreen,
              color: Colors.white,
            ),
      onPressed: () => videoStore.settingsStore.fullScreen = !videoStore.settingsStore.fullScreen,
    );

    final sleepTimerButton = IconButton(
      tooltip: 'Sleep timer',
      icon: const Icon(
        Icons.timer,
        color: Colors.white,
      ),
      onPressed: () => _showSleepTimerDialog(context),
    );

    final rotateButton = IconButton(
      tooltip: orientation == Orientation.portrait ? 'Enter landscape mode' : 'Exit landscape mode',
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
              settingsButton,
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

    final streamTitle = videoStore.streamInfo!.title.trim();
    final category = videoStore.streamInfo!.gameName.isNotEmpty ? videoStore.streamInfo!.gameName : 'No Category';

    final streamerName = regexEnglish.hasMatch(streamInfo.userName) ? streamInfo.userName : '${streamInfo.userName} (${streamInfo.userLogin})';

    final brightnessSlider = Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () => videoStore.handleVideoTap(),
        onVerticalDragUpdate:
            MediaQuery.of(context).orientation == Orientation.landscape
                ? (update) {
                    videoStore.handleBrightnessGesture(update.primaryDelta!);
                  }
                : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.3),
          child: Observer(builder: (_) {
            return Center(
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 500),
                  child: videoStore.brightnessUIVisible
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sunny,
                                color: Colors.white, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              '${videoStore.currentBrightnessPercentage}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  letterSpacing: 0.2,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        )
                      : Container()),
            );
          }),
        ),
      ),
    );

    final volumeSlider = Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: () => videoStore.handleVideoTap(),
        onVerticalDragUpdate:
            MediaQuery.of(context).orientation == Orientation.landscape
                ? (update) {
                    videoStore.handleVolumeGesture(update.primaryDelta!);
                  }
                : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.3),
          child: Observer(builder: (_) {
            return Center(
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 500),
                  child: videoStore.volumeUIVisible
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.volume_up,
                                color: Colors.white, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              '${videoStore.currentVolumePercentage}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  letterSpacing: 0.2,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        )
                      : Container()),
            );
          }),
        ),
      ),
    );

    return Observer(
      builder: (context) {
        return Stack(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [brightnessSlider, volumeSlider],
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                backButton,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ProfilePicture(
                              userLogin: streamInfo.userLogin,
                              radius: 10,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Tooltip(
                                message: streamerName,
                                child: Text(
                                  streamerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5.0),
                        Tooltip(
                          message: streamTitle,
                          child: Text(
                            streamTitle,
                            maxLines: orientation == Orientation.portrait ? 1 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (videoStore.settingsStore.fullScreen && orientation == Orientation.landscape) chatOverlayButton,
                sleepTimerButton,
                settingsButton,
              ],
            ),
            Center(
              child: IconButton(
                tooltip: videoStore.paused ? 'Play' : 'Pause',
                iconSize: 50.0,
                icon: videoStore.paused
                    ? const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.pause,
                        color: Colors.white,
                      ),
                onPressed: videoStore.handlePausePlay,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.games,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Tooltip(
                                  message: category,
                                  preferBelow: false,
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 14,
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
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: Colors.white,
                                    size: 14,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Picture-in-picture',
                    icon: const Icon(
                      Icons.picture_in_picture_alt_rounded,
                      color: Colors.white,
                    ),
                    onPressed: videoStore.requestPictureInPicture,
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

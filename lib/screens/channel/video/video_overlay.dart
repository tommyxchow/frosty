import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/channel/stores/video_store.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:intl/intl.dart';

class VideoOverlay extends StatelessWidget {
  final VideoStore videoStore;

  const VideoOverlay({Key? key, required this.videoStore}) : super(key: key);

  Future<void> _showSleepTimerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Timer'),
        content: Observer(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              if (videoStore.sleepTimer != null && videoStore.sleepTimer!.isActive)
                Row(
                  children: [
                    const Icon(Icons.timer),
                    Text(' ${videoStore.timeRemaining.toString().split('.')[0]}'),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Cancel Timer',
                      onPressed: videoStore.cancelSleepTimer,
                      icon: const Icon(Icons.cancel),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            style: TextButton.styleFrom(primary: Colors.red),
            child: const Text('Dismiss'),
          ),
          Observer(
            builder: (context) => ElevatedButton(
              onPressed: videoStore.sleepHours == 0 && videoStore.sleepMinutes == 0
                  ? null
                  : () => videoStore.updateSleepTimer(
                        onTimerFinished: () => navigatorKey.currentState?.popUntil((route) => route.isFirst),
                      ),
              child: const Text('Set Timer'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    final backButton = Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        tooltip: 'Back',
        icon: Icon(
          Icons.adaptive.arrow_back,
          color: Colors.white,
        ),
        onPressed: Navigator.of(context).pop,
      ),
    );

    final settingsButton = IconButton(
      tooltip: 'Settings',
      icon: const Icon(
        Icons.settings,
        color: Colors.white,
      ),
      onPressed: () => showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Settings(settingsStore: videoStore.settingsStore),
        ),
      ),
    );

    final chatOverlayButton = IconButton(
      tooltip: 'Toggle Chat Overlay',
      onPressed: () => videoStore.settingsStore.fullScreenChatOverlay = !videoStore.settingsStore.fullScreenChatOverlay,
      icon: const Icon(Icons.chat_bubble_outline),
      color: Colors.white,
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
      tooltip: videoStore.settingsStore.fullScreen ? 'Exit Fullscreen' : 'Enter Fullscreen',
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
      tooltip: 'Sleep Timer',
      icon: const Icon(
        Icons.timer,
        color: Colors.white,
      ),
      onPressed: () => _showSleepTimerDialog(context),
    );

    return Observer(
      builder: (context) {
        final streamInfo = videoStore.streamInfo;
        if (streamInfo == null) {
          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  backButton,
                  const Spacer(),
                  settingsButton,
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (videoStore.settingsStore.fullScreen && orientation == Orientation.landscape) chatOverlayButton,
                    refreshButton,
                    if (orientation == Orientation.landscape) fullScreenButton,
                  ],
                ),
              ),
            ],
          );
        }

        final streamerName = regexEnglish.hasMatch(streamInfo.userName) ? streamInfo.userName : '${streamInfo.userName} (${streamInfo.userLogin})';
        final streamer = Row(
          children: [
            ProfilePicture(
              userLogin: streamInfo.userLogin,
              radius: 10.0,
            ),
            const SizedBox(width: 5.0),
            Flexible(
              child: Tooltip(
                message: streamerName,
                preferBelow: false,
                child: Text(
                  streamerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );

        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                backButton,
                const Spacer(),
                sleepTimerButton,
                settingsButton,
              ],
            ),

            // Add a play button when paused for Android
            // When an ad is paused on Android there is no way to unpause, so a play button is necessary.
            if (Platform.isAndroid)
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
              )
            else if (!videoStore.paused)
              Center(
                child: IconButton(
                  tooltip: 'Pause',
                  iconSize: 50.0,
                  icon: const Icon(
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
                    child: GestureDetector(
                      onTap: videoStore.handleExpand,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: videoStore.settingsStore.expandInfo
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  streamer,
                                  const SizedBox(height: 5.0),
                                  Tooltip(
                                    message: videoStore.streamInfo!.title.trim(),
                                    preferBelow: false,
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      videoStore.streamInfo!.title.trim(),
                                      maxLines: orientation == Orientation.portrait ? 1 : 5,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    '${videoStore.streamInfo?.gameName} \u2022 ${NumberFormat().format(videoStore.streamInfo?.viewerCount)} viewers',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              )
                            : streamer,
                      ),
                    ),
                  ),
                  if (videoStore.settingsStore.fullScreen && orientation == Orientation.landscape) chatOverlayButton,
                  refreshButton,
                  if (Platform.isIOS && videoStore.settingsStore.pictureInPicture)
                    IconButton(
                      tooltip: 'Picture-in-Picture',
                      icon: const Icon(
                        Icons.picture_in_picture_alt_rounded,
                        color: Colors.white,
                      ),
                      onPressed: videoStore.requestPictureInPicture,
                    ),
                  if (orientation == Orientation.landscape) fullScreenButton
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

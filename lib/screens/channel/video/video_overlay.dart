import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/screens/channel/stores/video_store.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:intl/intl.dart';

class VideoOverlay extends StatefulWidget {
  final VideoStore videoStore;

  const VideoOverlay({Key? key, required this.videoStore}) : super(key: key);

  @override
  State<VideoOverlay> createState() => _VideoOverlayState();
}

class _VideoOverlayState extends State<VideoOverlay> {
  Future<void> _showSleepTimerDialog(BuildContext oldContext) {
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
                    value: widget.videoStore.sleepHours,
                    items: List.generate(24, (index) => index).map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                    onChanged: (int? hours) => widget.videoStore.sleepHours = hours!,
                    menuMaxHeight: 200,
                  ),
                  const SizedBox(width: 10.0),
                  const Text('Hours'),
                ],
              ),
              Row(
                children: [
                  DropdownButton(
                    value: widget.videoStore.sleepMinutes,
                    items: List.generate(60, (index) => index).map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                    onChanged: (int? minutes) => widget.videoStore.sleepMinutes = minutes!,
                    menuMaxHeight: 200,
                  ),
                  const SizedBox(width: 10.0),
                  const Text('Minutes'),
                ],
              ),
              if (widget.videoStore.sleepTimer != null && widget.videoStore.sleepTimer!.isActive)
                Row(
                  children: [
                    const Icon(Icons.timer),
                    Text(' ${widget.videoStore.timeRemaining.toString().split('.')[0]}'),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Cancel Timer',
                      onPressed: widget.videoStore.cancelSleepTimer,
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
            child: const Text('Dismiss'),
            style: TextButton.styleFrom(primary: Colors.red),
          ),
          Observer(
            builder: (context) => ElevatedButton(
              onPressed: widget.videoStore.sleepHours == 0 && widget.videoStore.sleepMinutes == 0
                  ? null
                  : () => widget.videoStore.updateSleepTimer(
                        onTimerFinished: () => Navigator.popUntil(
                          oldContext,
                          (route) => route.isFirst,
                        ),
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
          child: Settings(settingsStore: widget.videoStore.settingsStore),
        ),
      ),
    );

    final refreshButton = IconButton(
      tooltip: 'Refresh',
      icon: const Icon(
        Icons.refresh,
        color: Colors.white,
      ),
      onPressed: widget.videoStore.handleRefresh,
    );

    final fullScreenButton = IconButton(
      tooltip: widget.videoStore.settingsStore.fullScreen ? 'Exit Fullscreen' : 'Enter Fullscreen',
      icon: widget.videoStore.settingsStore.fullScreen
          ? const Icon(
              Icons.fullscreen_exit,
              color: Colors.white,
            )
          : const Icon(
              Icons.fullscreen,
              color: Colors.white,
            ),
      onPressed: () => widget.videoStore.settingsStore.fullScreen = !widget.videoStore.settingsStore.fullScreen,
    );

    final sleepTimerButton = IconButton(
      tooltip: 'Sleep Timer',
      icon: const Icon(
        Icons.timer,
        color: Colors.white,
      ),
      onPressed: () => _showSleepTimerDialog(context),
    );

    final streamInfo = widget.videoStore.streamInfo;

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
                refreshButton,
                if (orientation == Orientation.landscape) fullScreenButton,
              ],
            ),
          ),
        ],
      );
    }

    final streamer = Text(
      regexEnglish.hasMatch(streamInfo.userName) ? streamInfo.userName : streamInfo.userName + ' (${streamInfo.userLogin})',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );

    return Observer(
      builder: (context) => Stack(
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
                tooltip: widget.videoStore.paused ? 'Play' : 'Pause',
                iconSize: 50.0,
                icon: widget.videoStore.paused
                    ? const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.pause,
                        color: Colors.white,
                      ),
                onPressed: widget.videoStore.handlePausePlay,
              ),
            )
          else if (!widget.videoStore.paused)
            Center(
              child: IconButton(
                tooltip: 'Pause',
                iconSize: 50.0,
                icon: const Icon(
                  Icons.pause,
                  color: Colors.white,
                ),
                onPressed: widget.videoStore.handlePausePlay,
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.videoStore.handleExpand,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: widget.videoStore.settingsStore.expandInfo
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                streamer,
                                const SizedBox(height: 5.0),
                                Tooltip(
                                  message: widget.videoStore.streamInfo!.title.trim(),
                                  preferBelow: false,
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    widget.videoStore.streamInfo!.title.trim(),
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
                                  '${widget.videoStore.streamInfo?.gameName} \u2022 ${NumberFormat().format(widget.videoStore.streamInfo?.viewerCount)} viewers',
                                  style: const TextStyle(
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
                refreshButton,
                if (Platform.isIOS && widget.videoStore.settingsStore.pictureInPicture)
                  IconButton(
                    tooltip: 'Picture-in-Picture',
                    icon: const Icon(
                      Icons.picture_in_picture_alt_rounded,
                      color: Colors.white,
                    ),
                    onPressed: widget.videoStore.requestPictureInPicture,
                  ),
                if (orientation == Orientation.landscape) fullScreenButton
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.videoStore.cancelSleepTimer();
    super.dispose();
  }
}

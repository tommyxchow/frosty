import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/settings/settings.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VideoOverlay extends StatelessWidget {
  final VideoStore videoStore;

  const VideoOverlay({Key? key, required this.videoStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final portrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return GestureDetector(
      onTap: videoStore.handleVideoTap,
      child: SizedBox.expand(
        child: Observer(
          builder: (context) {
            return AnimatedOpacity(
              opacity: videoStore.menuVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 100),
              child: ColoredBox(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                child: IgnorePointer(
                  ignoring: !videoStore.menuVisible,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              if (!context.read<SettingsStore>().fullScreen)
                                IconButton(
                                  icon: Icon(
                                    Icons.adaptive.arrow_back,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings,
                                  color: Color(0xFFFFFFFF),
                                ),
                                onPressed: () => showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Settings(settingsStore: context.read<SettingsStore>());
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: videoStore.handleExpand,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: videoStore.streamInfo != null
                                        ? AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            child: videoStore.expandInfo
                                                ? Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        videoStore.streamInfo!.userName,
                                                        style: const TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5.0),
                                                      Text(
                                                        videoStore.streamInfo!.title,
                                                        maxLines: portrait ? 2 : 4,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 5.0),
                                                      Text(
                                                        '${videoStore.streamInfo?.gameName} for ${NumberFormat().format(videoStore.streamInfo?.viewerCount)} viewers',
                                                        style: const TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Align(
                                                    alignment: Alignment.bottomLeft,
                                                    child: Text(
                                                      videoStore.streamInfo!.userName,
                                                      style: const TextStyle(
                                                        color: Color(0xFFFFFFFF),
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              if (Platform.isIOS)
                                IconButton(
                                  icon: const Icon(
                                    Icons.picture_in_picture_alt_rounded,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                  onPressed: videoStore.requestPictureInPicture,
                                ),
                              if (MediaQuery.of(context).orientation == Orientation.landscape)
                                IconButton(
                                  icon: const Icon(
                                    Icons.fullscreen,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                  onPressed: () => context.read<SettingsStore>().fullScreen = !context.read<SettingsStore>().fullScreen,
                                )
                            ],
                          )
                        ],
                      ),
                      Center(
                        child: IconButton(
                          iconSize: 50.0,
                          icon: videoStore.paused
                              ? const Icon(
                                  Icons.play_arrow,
                                  color: Color(0xFFFFFFFF),
                                )
                              : const Icon(
                                  Icons.pause,
                                  color: Color(0xFFFFFFFF),
                                ),
                          onPressed: videoStore.handlePausePlay,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

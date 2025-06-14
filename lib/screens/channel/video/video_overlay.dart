import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/video/video_bar.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Creates a widget containing controls which enable interactions with an underlying [Video] widget.
class VideoOverlay extends StatelessWidget {
  final VideoStore videoStore;
  final ChatStore chatStore;
  final SettingsStore settingsStore;

  const VideoOverlay({
    super.key,
    required this.videoStore,
    required this.chatStore,
    required this.settingsStore,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    final surfaceColor =
        context.watch<FrostyThemes>().dark.colorScheme.onSurface;

    final backButton = IconButton(
      tooltip: 'Back',
      icon: Icon(
        Icons.adaptive.arrow_back_rounded,
        color: surfaceColor,
      ),
      onPressed: Navigator.of(context).pop,
    );

    final chatOverlayButton = Observer(
      builder: (_) => IconButton(
        tooltip: videoStore.settingsStore.fullScreenChatOverlay
            ? 'Hide chat overlay'
            : 'Show chat overlay',
        onPressed: () => videoStore.settingsStore.fullScreenChatOverlay =
            !videoStore.settingsStore.fullScreenChatOverlay,
        icon: videoStore.settingsStore.fullScreenChatOverlay
            ? const Icon(Icons.chat_rounded)
            : const Icon(Icons.chat_outlined),
        color: surfaceColor,
      ),
    );

    final videoSettingsButton = IconButton(
      icon: const Icon(Icons.settings),
      color: surfaceColor,
      onPressed: () {
        videoStore.updateStreamQualities();
        showModalBottomSheet(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                'Stream quality',
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                isFirst: true,
              ),
              Flexible(
                child: Observer(
                  builder: (context) => ListView(
                    shrinkWrap: true,
                    primary: false,
                    children: videoStore.availableStreamQualities
                        .map(
                          (quality) => ListTile(
                            trailing: videoStore.streamQuality == quality
                                ? const Icon(Icons.check_rounded)
                                : null,
                            title: Text(quality),
                            onTap: () {
                              videoStore.setStreamQuality(quality);
                              SharedPreferences.getInstance().then(
                                (prefs) => prefs.setString(
                                  'last_stream_quality',
                                  quality,
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    final latencyTooltip = Tooltip(
      message: 'Latency to broadcaster',
      preferBelow: false,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Observer(
              builder: (context) => Text(
                videoStore.latency ?? 'N/A',
                style: TextStyle(
                  color: surfaceColor,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Icon(
              Icons.speed_rounded,
              color: surfaceColor,
            ),
          ],
        ),
      ),
    );

    final refreshButton = Tooltip(
      message: 'Refresh',
      preferBelow: false,
      child: IconButton(
        icon: Icon(
          Icons.refresh_rounded,
          color: surfaceColor,
        ),
        onPressed: videoStore.handleRefresh,
      ),
    );

    final fullScreenButton = Tooltip(
      message: videoStore.settingsStore.fullScreen
          ? 'Exit fullscreen mode'
          : 'Enter fullscreen mode',
      preferBelow: false,
      child: IconButton(
        icon: Icon(
          videoStore.settingsStore.fullScreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          color: surfaceColor,
        ),
        onPressed: () => videoStore.settingsStore.fullScreen =
            !videoStore.settingsStore.fullScreen,
      ),
    );

    final rotateButton = Tooltip(
      message: orientation == Orientation.portrait
          ? 'Enter landscape mode'
          : 'Exit landscape mode',
      preferBelow: false,
      child: IconButton(
        icon: Icon(
          Icons.screen_rotation_rounded,
          color: surfaceColor,
        ),
        onPressed: () {
          if (orientation == Orientation.portrait) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          } else {
            SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp],
            );
            SystemChrome.setPreferredOrientations([]);
          }
        },
      ),
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
                  if (videoStore.settingsStore.fullScreen &&
                      orientation == Orientation.landscape)
                    chatOverlayButton,
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    refreshButton,
                    // On iPad, hide the rotate button on the overlay
                    // Flutter doesn't allow programmatic rotation on iPad unless multitasking is disabled.
                    if (!isIPad()) rotateButton,
                    if (orientation == Orientation.landscape) fullScreenButton,
                  ],
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                backButton,
                if (orientation == Orientation.landscape)
                  Expanded(
                    child: VideoBar(
                      streamInfo: streamInfo,
                      titleTextColor: surfaceColor,
                      subtitleTextColor: surfaceColor,
                      subtitleTextWeight: FontWeight.w500,
                    ),
                  ),
                if (videoStore.settingsStore.fullScreen &&
                    orientation == Orientation.landscape)
                  chatOverlayButton,
                if (!Platform.isIOS || isIPad())
                  Row(
                    children: [
                      Text(
                        videoStore.streamQuality,
                        style: TextStyle(
                          color: surfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      videoSettingsButton,
                    ],
                  ),
              ],
            ),
            Center(
              child: Tooltip(
                message: videoStore.paused ? 'Play' : 'Pause',
                preferBelow: false,
                child: IconButton(
                  iconSize: 56,
                  icon: Icon(
                    videoStore.paused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: surfaceColor,
                  ),
                  onPressed: videoStore.handlePausePlay,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Tooltip(
                            message: 'Stream uptime',
                            preferBelow: false,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Uptime(
                                  startTime: streamInfo.startedAt,
                                  style: TextStyle(
                                    color: surfaceColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Tooltip(
                            message: 'Viewer count',
                            preferBelow: false,
                            child: GestureDetector(
                              onTap: () => showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (context) => GestureDetector(
                                  onTap: FocusScope.of(context).unfocus,
                                  child: ChattersList(
                                    chatDetailsStore:
                                        chatStore.chatDetailsStore,
                                    chatStore: chatStore,
                                    userLogin: streamInfo.userLogin,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 14,
                                    color: surfaceColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    NumberFormat().format(
                                      videoStore.streamInfo?.viewerCount,
                                    ),
                                    style: TextStyle(
                                      color: surfaceColor,
                                      fontWeight: FontWeight.w500,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
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
                  if (orientation == Orientation.landscape &&
                      settingsStore.showLatency)
                    latencyTooltip,
                  Tooltip(
                    message: 'Enter picture-in-picture',
                    preferBelow: false,
                    child: IconButton(
                      icon: Icon(
                        Icons.picture_in_picture_alt_rounded,
                        color: surfaceColor,
                      ),
                      onPressed: videoStore.requestPictureInPicture,
                    ),
                  ),
                  refreshButton,
                  // On iPad, hide the rotate button on the overlay
                  // Flutter doesn't allow programmatic rotation on iPad unless multitasking is disabled.
                  if (!isIPad()) rotateButton,
                  if (orientation == Orientation.landscape) fullScreenButton,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

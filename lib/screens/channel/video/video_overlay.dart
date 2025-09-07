import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/video/stream_info_bar.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/live_indicator.dart';
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

  static const _iconShadow = [
    Shadow(
      offset: Offset(0, 1),
      blurRadius: 4,
      color: Color.fromRGBO(0, 0, 0, 0.3),
    ),
  ];

  static const _textShadow = [
    Shadow(
      offset: Offset(0, 1),
      blurRadius: 4,
      color: Color.fromRGBO(0, 0, 0, 0.3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final surfaceColor = context
        .watch<FrostyThemes>()
        .dark
        .colorScheme
        .onSurface;

    final backButton = IconButton(
      tooltip: 'Back',
      icon: Icon(
        Icons.adaptive.arrow_back_rounded,
        color: surfaceColor,
        shadows: _iconShadow,
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
            ? Icon(Icons.chat_rounded, shadows: _iconShadow)
            : Icon(Icons.chat_outlined, shadows: _iconShadow),
        color: surfaceColor,
      ),
    );

    final videoSettingsButton = IconButton(
      icon: Icon(Icons.settings, shadows: _iconShadow),
      color: surfaceColor,
      onPressed: () {
        videoStore.updateStreamQualities();
        showModalBottomSheetWithProperFocus(
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
      child: Row(
        spacing: 4,
        children: [
          Icon(
            Icons.speed_rounded,
            size: 14,
            color: surfaceColor,
            shadows: _iconShadow,
          ),
          Observer(
            builder: (context) => Text(
              videoStore.latency ?? 'N/A',
              style: TextStyle(
                color: surfaceColor,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
                shadows: _textShadow,
              ),
            ),
          ),
        ],
      ),
    );

    final refreshButton = Tooltip(
      message: 'Refresh',
      preferBelow: false,
      child: IconButton(
        icon: Icon(
          Icons.refresh_rounded,
          color: surfaceColor,
          shadows: _iconShadow,
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
          shadows: _iconShadow,
        ),
        onPressed: () => videoStore.settingsStore.fullScreen =
            !videoStore.settingsStore.fullScreen,
      ),
    );

    final rotateButton = Tooltip(
      message: context.isPortrait
          ? 'Enter landscape mode'
          : 'Exit landscape mode',
      preferBelow: false,
      child: IconButton(
        icon: Icon(
          Icons.screen_rotation_rounded,
          color: surfaceColor,
          shadows: _iconShadow,
        ),
        onPressed: () {
          if (context.isPortrait) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          } else {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
            SystemChrome.setPreferredOrientations([]);
          }
        },
      ),
    );

    return Observer(
      builder: (context) {
        final streamInfo = videoStore.streamInfo;
        final offlineChannelInfo = videoStore.offlineChannelInfo;

        // Top gradient - fades from top to bottom, covers top cluster area
        final topGradient = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black.withValues(alpha: 0.99),
              Colors.black.withValues(alpha: 0.98),
              Colors.black.withValues(alpha: 0.97),
              Colors.black.withValues(alpha: 0.96),
              Colors.black.withValues(alpha: 0.95),
              Colors.black.withValues(alpha: 0.93),
              Colors.black.withValues(alpha: 0.9),
              Colors.black.withValues(alpha: 0.87),
              Colors.black.withValues(alpha: 0.83),
              Colors.black.withValues(alpha: 0.75),
              Colors.black.withValues(alpha: 0.6),
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.08),
              Colors.black.withValues(alpha: 0.02),
              Colors.transparent,
            ],
            stops: [
              0.0, // Top: Full black - solid area for controls
              0.02, // Very slight fade start
              0.04, // Still very strong black
              0.06, // Strong black maintained
              0.08, // Still solid black
              0.12, // Very strong black - extended
              0.16, // Strong black - solid area
              0.22, // Still strong black
              0.28, // Solid black maintained
              0.35, // Strong black - almost halfway
              0.42, // Still very solid black
              0.5, // Halfway point - start smooth fade
              0.58, // Begin gradual fade
              0.67, // Smooth fade transition
              0.76, // Light fade
              0.85, // Very light
              1.0, // Bottom: Transparent - smooth fade out
            ],
          ),
        );

        // Bottom gradient - fades from bottom to top, covers bottom cluster area
        final bottomGradient = BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black,
              Colors.black.withValues(alpha: 0.99),
              Colors.black.withValues(alpha: 0.98),
              Colors.black.withValues(alpha: 0.97),
              Colors.black.withValues(alpha: 0.96),
              Colors.black.withValues(alpha: 0.95),
              Colors.black.withValues(alpha: 0.93),
              Colors.black.withValues(alpha: 0.9),
              Colors.black.withValues(alpha: 0.87),
              Colors.black.withValues(alpha: 0.83),
              Colors.black.withValues(alpha: 0.75),
              Colors.black.withValues(alpha: 0.6),
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.08),
              Colors.black.withValues(alpha: 0.02),
              Colors.transparent,
            ],
            stops: [
              0.0, // Bottom: Full black - solid area for controls
              0.02, // Very slight fade start
              0.04, // Still very strong black
              0.06, // Strong black maintained
              0.08, // Still solid black
              0.12, // Very strong black - extended
              0.16, // Strong black - solid area
              0.22, // Still strong black
              0.28, // Solid black maintained
              0.35, // Strong black - almost halfway
              0.42, // Still very solid black
              0.5, // Halfway point - start smooth fade
              0.58, // Begin gradual fade
              0.67, // Smooth fade transition
              0.76, // Light fade
              0.85, // Very light
              1.0, // Top: Transparent - smooth fade out
            ],
          ),
        );

        if (streamInfo == null) {
          return Stack(
            children: [
              // Top gradient behind top cluster
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100, // Covers top area around controls (extended)
                child: Container(decoration: topGradient),
              ),
              // Bottom gradient behind bottom cluster
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80, // Covers bottom area around controls
                child: Container(decoration: bottomGradient),
              ),
              // Content
              Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              backButton,
                              if (offlineChannelInfo != null)
                                Flexible(
                                  child: StreamInfoBar(
                                    offlineChannelInfo: offlineChannelInfo,
                                    displayName: chatStore.displayName,
                                    showUptime: false,
                                    showViewerCount: false,
                                    showOfflineIndicator: false,
                                    textColor: surfaceColor,
                                    isOffline: true,
                                    isInSharedChatMode:
                                        chatStore.isInSharedChatMode,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (videoStore.settingsStore.fullScreen &&
                          context.isLandscape)
                        chatOverlayButton,
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        'Offline',
                        style: TextStyle(
                          color: surfaceColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          shadows: _textShadow,
                        ),
                      ),
                    ),
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
                        if (context.isLandscape) fullScreenButton,
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Stack(
          children: [
            // Top gradient behind top cluster
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100, // Covers top area around controls (extended)
              child: Container(decoration: topGradient),
            ),
            // Bottom gradient behind bottom cluster
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80, // Covers bottom area around controls
              child: Container(decoration: bottomGradient),
            ),
            // Content
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            backButton,
                            Flexible(
                              child: Observer(
                                builder: (context) => StreamInfoBar(
                                  streamInfo: streamInfo,
                                  showUptime: false,
                                  showViewerCount: false,
                                  textColor: surfaceColor,
                                  isInSharedChatMode:
                                      chatStore.isInSharedChatMode,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (videoStore.settingsStore.fullScreen &&
                        context.isLandscape)
                      chatOverlayButton,
                    if (!Platform.isIOS || isIPad()) videoSettingsButton,
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
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 3),
                            blurRadius: 8,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ],
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            spacing: 8,
                            children: [
                              Tooltip(
                                message: 'Stream uptime',
                                preferBelow: false,
                                child: Row(
                                  spacing: 6,
                                  children: [
                                    const LiveIndicator(),
                                    Uptime(
                                      startTime: streamInfo.startedAt,
                                      style: TextStyle(
                                        color: surfaceColor,
                                        fontWeight: FontWeight.w500,
                                        shadows: _textShadow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Tooltip(
                                message: 'Viewer count',
                                preferBelow: false,
                                child: GestureDetector(
                                  onTap: () =>
                                      showModalBottomSheetWithProperFocus(
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
                                    spacing: 4,
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 14,
                                        shadows: _iconShadow,
                                        color: surfaceColor,
                                      ),
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
                                          shadows: _textShadow,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (context.isLandscape) latencyTooltip,
                            ],
                          ),
                        ),
                      ),
                      Builder(
                        builder: (_) {
                          // On iOS, show toggle behavior. On Android, always show enter PiP.
                          final isIOS = Platform.isIOS;
                          final showExitState = isIOS && videoStore.isInPipMode;

                          return Tooltip(
                            message: showExitState
                                ? 'Exit picture-in-picture'
                                : 'Enter picture-in-picture',
                            preferBelow: false,
                            child: IconButton(
                              icon: Icon(
                                showExitState
                                    ? Icons.picture_in_picture_alt_outlined
                                    : Icons.picture_in_picture_alt_rounded,
                                color: surfaceColor,
                                shadows: _iconShadow,
                              ),
                              onPressed: videoStore.togglePictureInPicture,
                            ),
                          );
                        },
                      ),
                      refreshButton,
                      // On iPad, hide the rotate button on the overlay
                      // Flutter doesn't allow programmatic rotation on iPad unless multitasking is disabled.
                      if (!isIPad()) rotateButton,
                      if (context.isLandscape) fullScreenButton,
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_assets_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/video/video.dart';
import 'package:frosty/screens/channel/video/video_bar.dart';
import 'package:frosty/screens/channel/video/video_overlay.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:frosty/widgets/draggable_divider.dart';
import 'package:frosty/widgets/notification.dart';
import 'package:provider/provider.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'package:simple_pip_mode/pip_widget.dart';

/// Creates a widget that shows the video stream (if live) and chat of the given user.
class VideoChat extends StatefulWidget {
  final String userId;
  final String userName;
  final String userLogin;

  const VideoChat({
    super.key,
    required this.userId,
    required this.userName,
    required this.userLogin,
  });

  @override
  State<VideoChat> createState() => _VideoChatState();
}

class _VideoChatState extends State<VideoChat> {
  final _videoKey = GlobalKey();
  final _chatKey = GlobalKey();

  late final ChatStore _chatStore = ChatStore(
    twitchApi: context.read<TwitchApi>(),
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
    final orientation = MediaQuery.of(context).orientation;
    final theme = Theme.of(context);

    final settingsStore = _chatStore.settings;

    final player = GestureDetector(
      onLongPress: _videoStore.handleToggleOverlay,
      child: Video(
        key: _videoKey,
        videoStore: _videoStore,
      ),
    );

    final overlay = GestureDetector(
      onLongPress: _videoStore.handleToggleOverlay,
      onDoubleTap: orientation == Orientation.landscape
          ? () => settingsStore.fullScreen = !settingsStore.fullScreen
          : null,
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
          final videoOverlay = VideoOverlay(
            videoStore: _videoStore,
            chatStore: _chatStore,
            settingsStore: settingsStore,
          );

          if (_videoStore.paused || _videoStore.streamInfo == null) {
            return videoOverlay;
          }

          return AnimatedOpacity(
            opacity: _videoStore.overlayVisible ? 1.0 : 0.0,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black
                    .withValues(alpha: settingsStore.overlayOpacity),
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

    final chat = Observer(
      builder: (context) {
        final videoBarVisible = _videoStore.streamInfo != null &&
            _chatStore.settings.showVideo &&
            (_videoStore.paused || _videoStore.overlayVisible);

        return Stack(
          children: [
            Chat(
              key: _chatKey,
              chatStore: _chatStore,
            ),
            if (orientation == Orientation.portrait)
              AnimatedOpacity(
                opacity: videoBarVisible ? 1 : 0,
                curve: Curves.ease,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !videoBarVisible,
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_videoStore.streamInfo != null)
                          VideoBar(
                            streamInfo: _videoStore.streamInfo!,
                            tappableCategory: false,
                          ),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _chatStore.notification != null
                  ? Align(
                      alignment: _chatStore.settings.chatNotificationsOnBottom
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      child: FrostyNotification(
                        message: _chatStore.notification!,
                        onDismissed: () => _chatStore.clearNotification(),
                      ),
                    )
                  : null,
            ),
          ],
        );
      },
    );

    return Observer(
      builder: (context) {
        final videoChat = Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: (settingsStore.showVideo ||
                  (orientation == Orientation.landscape &&
                      !settingsStore.landscapeForceVerticalChat))
              ? null
              : AppBar(
                  centerTitle: false,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: theme.brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                  ),
                  leading: IconButton(
                    tooltip: 'Back',
                    icon: Icon(Icons.adaptive.arrow_back_rounded),
                    onPressed: Navigator.of(context).pop,
                  ),
                  title: Text(
                    getReadableName(
                      _chatStore.displayName,
                      _chatStore.channelName,
                    ),
                  ),
                ),
          body: Stack(
            children: [
              // Main content
              Observer(
                builder: (context) {
                  if (orientation == Orientation.landscape &&
                      !settingsStore.landscapeForceVerticalChat) {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.immersiveSticky,
                    );

                    final landscapeChat = AnimatedContainer(
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 200),
                      width: _chatStore.expandChat
                          ? MediaQuery.of(context).size.width / 2
                          : MediaQuery.of(context).size.width *
                              _chatStore.settings.chatWidth,
                      color: _chatStore.settings.fullScreen
                          ? Colors.black.withValues(
                              alpha: _chatStore
                                  .settings.fullScreenChatOverlayOpacity,
                            )
                          : Theme.of(context).scaffoldBackgroundColor,
                      child: chat,
                    );

                    final overlayChat = Visibility(
                      visible: settingsStore.fullScreenChatOverlay,
                      maintainState: true,
                      child: Theme(
                        data: FrostyThemes(
                          colorSchemeSeed: Color(settingsStore.accentColor),
                        ).dark,
                        child: DefaultTextStyle(
                          style: DefaultTextStyle.of(context).style.copyWith(
                                color: context
                                    .watch<FrostyThemes>()
                                    .dark
                                    .colorScheme
                                    .onSurface,
                              ),
                          child: landscapeChat,
                        ),
                      ),
                    );

                    return ColoredBox(
                      color: settingsStore.showVideo
                          ? Colors.black
                          : Theme.of(context).scaffoldBackgroundColor,
                      child: SafeArea(
                        bottom: false,
                        left: (settingsStore.landscapeCutout ==
                                    LandscapeCutoutType.both ||
                                settingsStore.landscapeCutout ==
                                    LandscapeCutoutType.left)
                            ? false
                            : true,
                        right: (settingsStore.landscapeCutout ==
                                    LandscapeCutoutType.both ||
                                settingsStore.landscapeCutout ==
                                    LandscapeCutoutType.right)
                            ? false
                            : true,
                        child: settingsStore.showVideo
                            ? settingsStore.fullScreen
                                ? Stack(
                                    children: [
                                      player,
                                      if (settingsStore.showOverlay)
                                        Row(
                                          children: settingsStore
                                                  .landscapeChatLeftSide
                                              ? [
                                                  overlayChat,
                                                  Expanded(child: overlay),
                                                ]
                                              : [
                                                  Expanded(child: overlay),
                                                  overlayChat,
                                                ],
                                        ),
                                    ],
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final totalWidth = constraints.maxWidth;
                                      final chatWidth = _chatStore.expandChat
                                          ? 0.5
                                          : _chatStore.settings.chatWidth;

                                      // Create the landscape chat container with proper styling
                                      final chatContainer = AnimatedContainer(
                                        curve: Curves.ease,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: totalWidth * chatWidth,
                                        color: _chatStore.settings.fullScreen
                                            ? Colors.black.withValues(
                                                alpha: _chatStore.settings
                                                    .fullScreenChatOverlayOpacity,
                                              )
                                            : Theme.of(context)
                                                .scaffoldBackgroundColor,
                                        child: chat,
                                      );

                                      final draggableDivider = Observer(
                                        builder: (_) => DraggableDivider(
                                          currentWidth: chatWidth,
                                          maxWidth: 0.6,
                                          isResizableOnLeft: settingsStore
                                              .landscapeChatLeftSide,
                                          showHandle:
                                              _videoStore.overlayVisible,
                                          onDrag: (newWidth) {
                                            if (!_chatStore.expandChat) {
                                              _chatStore.settings.chatWidth =
                                                  newWidth;
                                            }
                                          },
                                        ),
                                      );

                                      return Row(
                                        children:
                                            settingsStore.landscapeChatLeftSide
                                                ? [
                                                    chatContainer,
                                                    draggableDivider,
                                                    Expanded(child: video),
                                                  ]
                                                : [
                                                    Expanded(child: video),
                                                    draggableDivider,
                                                    chatContainer,
                                                  ],
                                      );
                                    },
                                  )
                            : Stack(
                                children: [
                                  // Chat content with proper padding for app bar
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: kToolbarHeight,
                                      ),
                                      child: chat,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }

                  SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.manual,
                    overlays: SystemUiOverlay.values,
                  );
                  return Stack(
                    children: [
                      // Main content
                      Positioned.fill(
                        child: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: settingsStore.showVideo ? 0 : kToolbarHeight,
                            ),
                            child: Column(
                              children: [
                                if (settingsStore.showVideo) ...[
                                  _PipDragGestureWrapper(
                                    videoStore: _videoStore,
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: video,
                                    ),
                                  ),
                                  const Divider(),
                                ],
                                Expanded(child: chat),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Blurred app bar overlay (only when not in fullscreen)
              Observer(
                builder: (context) {
                  if ((orientation == Orientation.landscape &&
                          !settingsStore.landscapeForceVerticalChat) ||
                      settingsStore.showVideo) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: BlurredContainer(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        left: MediaQuery.of(context).padding.left,
                        right: MediaQuery.of(context).padding.right,
                      ),
                      child: const SizedBox(height: kToolbarHeight),
                    ),
                  );
                },
              ),
            ],
          ),
        );

        // If on Android, use PiPSwitcher to enable PiP functionality.
        if (Platform.isAndroid) {
          return PipWidget(
            pipLayout: PipActionsLayout.mediaOnlyPause,
            onPipAction: (_) => _videoStore.handlePausePlay(),
            pipChild: player,
            child: videoChat,
          );
        }

        return videoChat;
      },
    );
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

/// A wrapper widget that handles drag-down gestures to trigger PiP mode with animation.
class _PipDragGestureWrapper extends StatefulWidget {
  final VideoStore videoStore;
  final Widget child;

  const _PipDragGestureWrapper({
    required this.videoStore,
    required this.child,
  });

  @override
  State<_PipDragGestureWrapper> createState() => _PipDragGestureWrapperState();
}

class _PipDragGestureWrapperState extends State<_PipDragGestureWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isDragging = false;
  double _dragDistance = 0;
  static const double _triggerDistance = 100; // Distance to trigger PiP
  static const double _maxDragDistance =
      150; // Maximum drag distance for animation

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.6,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragDistance = 0;
    HapticFeedback.lightImpact();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragDistance += details.delta.dy;
      _dragDistance = _dragDistance.clamp(0, _maxDragDistance);
    });

    // Update animation progress based on drag distance
    final progress = (_dragDistance / _maxDragDistance).clamp(0.0, 1.0);
    _animationController.value = progress;

    // Provide haptic feedback at trigger point
    if (_dragDistance >= _triggerDistance &&
        details.delta.dy > 0 &&
        _animationController.value >= _triggerDistance / _maxDragDistance) {
      HapticFeedback.mediumImpact();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    _isDragging = false;

    if (_dragDistance >= _triggerDistance) {
      // Trigger PiP mode
      HapticFeedback.heavyImpact();
      widget.videoStore.requestPictureInPicture();
    }

    // Reset animation
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _dragDistance = 0;
        });
      }
    });
  }

  void _handleDragCancel() {
    if (!_isDragging) return;

    _isDragging = false;

    // Reset animation
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _dragDistance = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      onPanCancel: _handleDragCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              _dragDistance * 0.5,
            ), // Move down but less than drag distance
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

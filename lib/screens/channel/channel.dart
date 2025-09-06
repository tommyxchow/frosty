import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_assets_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/video/stream_info_bar.dart';
import 'package:frosty/screens/channel/video/video.dart';
import 'package:frosty/screens/channel/video/video_overlay.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';
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

class _VideoChatState extends State<VideoChat>
    with SingleTickerProviderStateMixin {
  final _videoKey = GlobalKey();
  final _chatKey = GlobalKey();

  // PiP drag state - essential only
  double _pipDragDistance = 0;
  bool _isPipDragging = false;
  bool _isInPipTriggerZone =
      false; // Track when in trigger zone for haptic feedback

  // Essential constants for good UX balance
  static const double _pipTriggerDistance = 80;
  static const double _pipMaxDragDistance = 150;

  // Animation controller for smooth spring-back
  late AnimationController _animationController;
  late Animation<double> _springBackAnimation;

  late final ChatStore _chatStore = ChatStore(
    twitchApi: context.twitchApi,
    channelName: widget.userLogin,
    channelId: widget.userId,
    displayName: widget.userName,
    auth: context.authStore,
    settings: context.settingsStore,
    chatDetailsStore: ChatDetailsStore(
      twitchApi: context.twitchApi,
      channelName: widget.userLogin,
    ),
    assetsStore: ChatAssetsStore(
      twitchApi: context.twitchApi,
      ffzApi: context.ffzApi,
      bttvApi: context.bttvApi,
      sevenTVApi: context.sevenTVApi,
    ),
  );

  late final VideoStore _videoStore = VideoStore(
    userLogin: widget.userLogin,
    twitchApi: context.twitchApi,
    authStore: context.authStore,
    settingsStore: context.settingsStore,
  );

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for smooth drag interactions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Spring-back animation with smooth easing
    _springBackAnimation =
        Tween<double>(begin: 0, end: 0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        )..addListener(() {
          setState(() {
            _pipDragDistance = _springBackAnimation.value;
          });
        });
  }

  void _handlePipDragStart(DragStartDetails details) {
    // Disable drag gesture when already in PiP mode or video is not playing
    if (_videoStore.isInPipMode || _videoStore.paused) return;

    _animationController.stop(); // Stop any ongoing animation
    setState(() {
      _isPipDragging = true;
      _pipDragDistance = 0;
      _isInPipTriggerZone = false;
    });
  }

  void _handlePipDragUpdate(DragUpdateDetails details) {
    if (!_isPipDragging || _videoStore.isInPipMode || _videoStore.paused) {
      return;
    }

    setState(() {
      _pipDragDistance += details.delta.dy;
      _pipDragDistance = _pipDragDistance.clamp(0, _pipMaxDragDistance);

      // Check if we've entered or exited the trigger zone for haptic feedback
      final wasInTriggerZone = _isInPipTriggerZone;
      _isInPipTriggerZone = _pipDragDistance >= _pipTriggerDistance;

      // Provide haptic feedback when entering the trigger zone
      if (!wasInTriggerZone && _isInPipTriggerZone) {
        HapticFeedback.mediumImpact(); // Entering trigger zone
      }
      // Provide subtle haptic feedback when exiting the trigger zone
      else if (wasInTriggerZone && !_isInPipTriggerZone) {
        HapticFeedback.lightImpact(); // Exiting trigger zone
      }
    });
  }

  void _handlePipDragEnd(DragEndDetails details) {
    if (!_isPipDragging || _videoStore.isInPipMode || _videoStore.paused) {
      return;
    }

    final velocity = details.velocity.pixelsPerSecond.dy;
    final shouldTriggerPip =
        _pipDragDistance >= _pipTriggerDistance ||
        velocity > 600; // Simple velocity threshold

    if (shouldTriggerPip) {
      // Simple haptic feedback on success
      HapticFeedback.mediumImpact();
      _videoStore.requestPictureInPicture();
      _resetDragState();
    } else {
      // Animate back to original position
      _animateSpringBack();
    }
  }

  void _handlePipDragCancel() {
    if (!_isPipDragging) return;
    _animateSpringBack();
  }

  void _resetDragState() {
    setState(() {
      _isPipDragging = false;
      _pipDragDistance = 0;
      _isInPipTriggerZone = false;
    });
  }

  void _animateSpringBack() {
    _springBackAnimation = Tween<double>(begin: _pipDragDistance, end: 0)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _animationController.reset();
    _animationController.forward().then((_) {
      _resetDragState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsStore = _chatStore.settings;

    final player = GestureDetector(
      onLongPress: _videoStore.handleToggleOverlay,
      child: Video(key: _videoKey, videoStore: _videoStore),
    );

    final overlay = GestureDetector(
      onLongPress: _videoStore.handleToggleOverlay,
      onDoubleTap: context.isLandscape
          ? () => settingsStore.fullScreen = !settingsStore.fullScreen
          : null,
      onTap: () {
        if (_chatStore.assetsStore.showEmoteMenu) {
          _chatStore.assetsStore.showEmoteMenu = false;
        } else {
          if (_chatStore.textFieldFocusNode.hasFocus) {
            _chatStore.unfocusInput();
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
                color: Colors.black.withValues(
                  alpha: settingsStore.overlayOpacity,
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

        return Stack(children: [player, overlay]);
      },
    );

    final chat = Observer(
      builder: (context) {
        final bool chatOnly = !_chatStore.settings.showVideo;

        return Stack(
          children: [
            Chat(
              key: _chatKey,
              chatStore: _chatStore,
              listPadding: chatOnly
                  ? EdgeInsets.only(top: context.safePaddingTop)
                  : null,
            ),
            Observer(
              builder: (_) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _chatStore.notification != null
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: chatOnly ? context.safePaddingTop : 0,
                          ),
                          child: FrostyNotification(
                            message: _chatStore.notification!,
                            onDismissed: _chatStore.clearNotification,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );

    final videoChat = Observer(
      builder: (context) {
        // Build a blurred AppBar when in chat-only mode (no video)
        PreferredSizeWidget? chatOnlyBlurredAppBar;
        if (!settingsStore.showVideo) {
          final streamInfo = _videoStore.streamInfo;

          chatOnlyBlurredAppBar = AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  context.theme.brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            title: StreamInfoBar(
              streamInfo: streamInfo,
              displayName: _chatStore.displayName,
              isCompact: true,
              isOffline: streamInfo == null,
              isInSharedChatMode: _chatStore.isInSharedChatMode,
            ),
            flexibleSpace: BlurredContainer(
              gradientDirection: GradientDirection.up,
              child: Column(
                children: [
                  const Expanded(child: SizedBox.expand()),
                  AnimatedScrollBorder(
                    scrollController: _chatStore.scrollController,
                    isReversed: true,
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: chatOnlyBlurredAppBar,
          body: Observer(
            builder: (context) {
              if (context.isLandscape &&
                  !settingsStore.landscapeForceVerticalChat) {
                SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.immersiveSticky,
                );

                final landscapeChat = AnimatedContainer(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 200),
                  width: _chatStore.expandChat
                      ? context.screenWidth / 2
                      : context.screenWidth * _chatStore.settings.chatWidth,
                  color: _chatStore.settings.fullScreen
                      ? Colors.black.withValues(
                          alpha:
                              _chatStore.settings.fullScreenChatOverlayOpacity,
                        )
                      : context.scaffoldColor,
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
                      style: context.defaultTextStyle.copyWith(
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
                      : context.scaffoldColor,
                  child: settingsStore.showVideo
                      ? settingsStore.fullScreen
                            ? Stack(
                                children: [
                                  player,
                                  if (settingsStore.showOverlay)
                                    Row(
                                      children:
                                          settingsStore.landscapeChatLeftSide
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
                                    duration: const Duration(milliseconds: 200),
                                    width: totalWidth * chatWidth,
                                    color: _chatStore.settings.fullScreen
                                        ? Colors.black.withValues(
                                            alpha: _chatStore
                                                .settings
                                                .fullScreenChatOverlayOpacity,
                                          )
                                        : context.scaffoldColor,
                                    child: chat,
                                  );

                                  final draggableDivider = Observer(
                                    builder: (_) => DraggableDivider(
                                      currentWidth: chatWidth,
                                      maxWidth: 0.6,
                                      isResizableOnLeft:
                                          settingsStore.landscapeChatLeftSide,
                                      showHandle: _videoStore.overlayVisible,
                                      onDrag: (newWidth) {
                                        if (!_chatStore.expandChat) {
                                          _chatStore.settings.chatWidth =
                                              newWidth;
                                        }
                                      },
                                    ),
                                  );

                                  return SafeArea(
                                    child: Row(
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
                                    ),
                                  );
                                },
                              )
                      : chat,
                );
              }

              SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.manual,
                overlays: SystemUiOverlay.values,
              );
              return SafeArea(
                // Keep chat-only scrolling under the blurred app bar, but
                // ensure video does not bleed into the system status bar.
                top: settingsStore.showVideo,
                bottom: false,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        if (settingsStore.showVideo) ...[
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(), // Placeholder for video space
                          ),
                          const Divider(),
                        ],
                        Expanded(child: chat),
                      ],
                    ),
                    if (settingsStore.showVideo)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _animationController,
                            _springBackAnimation,
                          ]),
                          builder: (context, child) {
                            // Calculate current drag distance from either manual drag or animation
                            final currentDragDistance = _isPipDragging
                                ? _pipDragDistance
                                : (_springBackAnimation.value);

                            // Simple scale effect for visual feedback
                            final scaleFactor =
                                1.0 -
                                (currentDragDistance /
                                    _pipMaxDragDistance *
                                    0.1);

                            // Only apply rounded corners when dragging or animating
                            final shouldHaveRoundedCorners =
                                _isPipDragging || currentDragDistance > 0;
                            final borderRadius = shouldHaveRoundedCorners
                                ? BorderRadius.circular(8)
                                : BorderRadius.zero;

                            return Transform.translate(
                              offset: Offset(0, currentDragDistance),
                              child: Transform.scale(
                                scale: scaleFactor.clamp(0.9, 1.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: borderRadius,
                                      child: GestureDetector(
                                        onPanStart: _handlePipDragStart,
                                        onPanUpdate: _handlePipDragUpdate,
                                        onPanEnd: _handlePipDragEnd,
                                        onPanCancel: _handlePipDragCancel,
                                        child: AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: video,
                                        ),
                                      ),
                                    ),
                                    // Simple text overlay that follows the video
                                    if (_isPipDragging &&
                                        !_videoStore.isInPipMode)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black.withValues(
                                            alpha: 0.4,
                                          ),
                                          child: Center(
                                            child: AnimatedOpacity(
                                              opacity: _pipDragDistance > 20
                                                  ? 1.0
                                                  : 0.0,
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              child: const Text(
                                                'Swipe down to enter picture-in-picture',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_tabs_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_tabs.dart';
import 'package:frosty/screens/channel/video/stream_info_bar.dart';
import 'package:frosty/screens/channel/video/video.dart';
import 'package:frosty/screens/channel/video/video_overlay.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:frosty/widgets/draggable_divider.dart';
import 'package:frosty/widgets/frosty_notification.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _videoKey = GlobalKey();
  final _chatKey = GlobalKey();

  // PiP drag state - essential only
  double _pipDragDistance = 0;
  bool _isPipDragging = false;
  bool _isInPipTriggerZone =
      false; // Track when in trigger zone for haptic feedback

  // Divider drag state for synchronizing animation
  bool _isDividerDragging = false;

  // Essential constants for good UX balance
  static const double _pipTriggerDistance = 80;
  static const double _pipMaxDragDistance = 150;

  // Animation controller for smooth spring-back
  late AnimationController _animationController;
  late Animation<double> _springBackAnimation;

  late final ChatTabsStore _chatTabsStore = ChatTabsStore(
    twitchApi: context.twitchApi,
    bttvApi: context.bttvApi,
    ffzApi: context.ffzApi,
    sevenTVApi: context.sevenTVApi,
    authStore: context.authStore,
    settingsStore: context.settingsStore,
    globalAssetsStore: context.globalAssetsStore,
    primaryChannelId: widget.userId,
    primaryChannelLogin: widget.userLogin,
    primaryDisplayName: widget.userName,
  );

  late final VideoStore _videoStore = VideoStore(
    userLogin: widget.userLogin,
    userId: widget.userId,
    twitchApi: context.twitchApi,
    authStore: context.authStore,
    settingsStore: context.settingsStore,
  );

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for smooth drag interactions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Spring-back animation with smooth easing
    _springBackAnimation =
        Tween<double>(begin: 0, end: 0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        )..addListener(() {
          setState(() {
            _pipDragDistance = _springBackAnimation.value;
          });
        });

    // Register as observer for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _videoStore.handleAppResume();
    }
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
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.reset();
    _animationController.forward().then((_) {
      _resetDragState();
    });
  }

  /// Wraps a video widget with PiP swipe-down gesture handling.
  ///
  /// Provides visual feedback (translate + scale), haptic feedback,
  /// and an instructional overlay during the drag gesture.
  Widget _buildPipGestureWrapper({required Widget child, double? aspectRatio}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _springBackAnimation]),
      builder: (context, _) {
        final currentDragDistance = _isPipDragging
            ? _pipDragDistance
            : _springBackAnimation.value;

        final scaleFactor =
            1.0 - (currentDragDistance / _pipMaxDragDistance * 0.1);

        Widget content = child;
        if (aspectRatio != null) {
          content = AspectRatio(aspectRatio: aspectRatio, child: child);
        }

        return Transform.translate(
          offset: Offset(0, currentDragDistance),
          child: Transform.scale(
            scale: scaleFactor.clamp(0.9, 1.0),
            child: Stack(
              children: [
                GestureDetector(
                  onPanStart: _handlePipDragStart,
                  onPanUpdate: _handlePipDragUpdate,
                  onPanEnd: _handlePipDragEnd,
                  onPanCancel: _handlePipDragCancel,
                  child: content,
                ),
                if (!_videoStore.isInPipMode)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: !(_isPipDragging && _pipDragDistance > 0),
                      child: AnimatedOpacity(
                        opacity: (_isPipDragging && _pipDragDistance > 0)
                            ? 1.0
                            : 0.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: const Center(
                            child: Text(
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
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Convenience getter for the currently active chat store.
  ChatStore get _chatStore => _chatTabsStore.activeChatStore;

  @override
  Widget build(BuildContext context) {
    final settingsStore = _chatTabsStore.settingsStore;

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
            child: ColoredBox(
              color: Colors.transparent,
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
        final bool chatOnly = !settingsStore.showVideo;

        return Stack(
          children: [
            ChatTabs(
              key: _chatKey,
              chatTabsStore: _chatTabsStore,
              // In chat-only mode, account for the blurred AppBar height
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
              offlineChannelInfo: _videoStore.offlineChannelInfo,
              displayName: _chatStore.displayName,
              isCompact: true,
              isOffline: streamInfo == null,
              isInSharedChatMode: _chatStore.isInSharedChatMode,
              showTextShadows: false,
            ),
            flexibleSpace: BlurredContainer(
              gradientDirection: GradientDirection.up,
              child: const SizedBox.expand(),
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
                  duration: _isDividerDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  width: _chatStore.expandChat
                      ? context.screenWidth / 2
                      : context.screenWidth * settingsStore.chatWidth,
                  color: settingsStore.fullScreen
                      ? Colors.black.withValues(
                          alpha: settingsStore.fullScreenChatOverlayOpacity,
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
                        shadows: settingsStore.fullScreen && context.isLandscape
                            ? const [
                                Shadow(blurRadius: 8),
                                Shadow(blurRadius: 4, offset: Offset(1, 1)),
                              ]
                            : null,
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
                                  _buildPipGestureWrapper(child: player),
                                  if (settingsStore.showOverlay)
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final totalWidth = constraints.maxWidth;
                                        final chatWidth = _chatStore.expandChat
                                            ? 0.5
                                            : settingsStore.chatWidth;

                                        final draggableDivider = Observer(
                                          builder: (_) => DraggableDivider(
                                            currentWidth: chatWidth,
                                            maxWidth: 0.6,
                                            isResizableOnLeft: settingsStore
                                                .landscapeChatLeftSide,
                                            showHandle:
                                                _videoStore.overlayVisible &&
                                                settingsStore
                                                    .fullScreenChatOverlay,
                                            onDragStart: () {
                                              setState(() {
                                                _isDividerDragging = true;
                                              });
                                            },
                                            onDrag: (newWidth) {
                                              if (!_chatStore.expandChat) {
                                                settingsStore.chatWidth =
                                                    newWidth;
                                              }
                                            },
                                            onDragEnd: () {
                                              setState(() {
                                                _isDividerDragging = false;
                                              });
                                            },
                                          ),
                                        );

                                        return Stack(
                                          children: [
                                            Row(
                                              children:
                                                  settingsStore
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
                                            Positioned(
                                              top: 0,
                                              bottom: 0,
                                              left:
                                                  settingsStore
                                                      .landscapeChatLeftSide
                                                  ? (totalWidth * chatWidth) -
                                                        12
                                                  : null,
                                              right:
                                                  !settingsStore
                                                      .landscapeChatLeftSide
                                                  ? (totalWidth * chatWidth) -
                                                        12
                                                  : null,
                                              child: draggableDivider,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                ],
                              )
                            : NativeDeviceOrientationReader(
                                useSensor: true,
                                builder: (context) {
                                  final orientation =
                                      NativeDeviceOrientationReader.orientation(
                                        context,
                                      );

                                  // Determine which side to fill based on setting
                                  final bool fillLeft;
                                  final bool fillRight;

                                  if (settingsStore.landscapeFillAllEdges) {
                                    fillLeft = true;
                                    fillRight = true;
                                  } else {
                                    // Auto mode: fill the physical bottom side (opposite of notch)
                                    // landscapeLeft = notch on left → fill right
                                    // landscapeRight = notch on right → fill left
                                    fillLeft =
                                        orientation ==
                                        NativeDeviceOrientation.landscapeRight;
                                    fillRight =
                                        orientation ==
                                        NativeDeviceOrientation.landscapeLeft;
                                  }

                                  return SafeArea(
                                    bottom: false,
                                    left: !fillLeft,
                                    right: !fillRight,
                                    child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final availableWidth = constraints.maxWidth;
                                    final chatWidth = _chatStore.expandChat
                                        ? 0.5
                                        : settingsStore.chatWidth;

                                    // Create the landscape chat container with proper styling
                                    final chatContainer = AnimatedContainer(
                                      curve: Curves.ease,
                                      duration: _isDividerDragging
                                          ? Duration.zero
                                          : const Duration(milliseconds: 200),
                                      width: availableWidth * chatWidth,
                                      color: settingsStore.fullScreen
                                          ? Colors.black.withValues(
                                              alpha: settingsStore
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
                                        onDragStart: () {
                                          setState(() {
                                            _isDividerDragging = true;
                                          });
                                        },
                                        onDrag: (newWidth) {
                                          if (!_chatStore.expandChat) {
                                            settingsStore.chatWidth = newWidth;
                                          }
                                        },
                                        onDragEnd: () {
                                          setState(() {
                                            _isDividerDragging = false;
                                          });
                                        },
                                      ),
                                    );

                                    return Stack(
                                      children: [
                                        Row(
                                          children:
                                              settingsStore
                                                  .landscapeChatLeftSide
                                              ? [
                                                  chatContainer,
                                                  Expanded(
                                                    child:
                                                        _buildPipGestureWrapper(
                                                          child: video,
                                                        ),
                                                  ),
                                                ]
                                              : [
                                                  Expanded(
                                                    child:
                                                        _buildPipGestureWrapper(
                                                          child: video,
                                                        ),
                                                  ),
                                                  chatContainer,
                                                ],
                                        ),
                                        Positioned(
                                          top: 0,
                                          bottom: 0,
                                          left:
                                              settingsStore
                                                  .landscapeChatLeftSide
                                              ? (availableWidth * chatWidth) -
                                                    12
                                              : null,
                                          right:
                                              !settingsStore
                                                  .landscapeChatLeftSide
                                              ? (availableWidth * chatWidth) -
                                                    12
                                              : null,
                                          child: draggableDivider,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                  );
                                },
                              )
                      : SafeArea(child: chat),
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
                        ],
                        Expanded(child: chat),
                      ],
                    ),
                    if (settingsStore.showVideo)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _buildPipGestureWrapper(
                          child: video,
                          aspectRatio: 16 / 9,
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
    // Remove observer for app lifecycle events
    WidgetsBinding.instance.removeObserver(this);

    _chatTabsStore.dispose();

    _videoStore.dispose();

    _animationController.dispose();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    SystemChrome.setPreferredOrientations([]);

    super.dispose();
  }
}

import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'video_store.g.dart';

class VideoStore = VideoStoreBase with _$VideoStore;

abstract class VideoStoreBase with Store {
  final TwitchApi twitchApi;

  /// The userlogin of the current channel.
  final String userLogin;

  final AuthStore authStore;

  final SettingsStore settingsStore;

  /// The [SimplePip] instance used for initiating PiP on Android.
  final pip = SimplePip();

  /// The webview controller used for injecting JavaScript to control the webview and video player.
  WebViewController? controller;

  @readonly
  VideoPlayerController? _videoPlayerController;

  /// The timer that handles hiding the overlay automatically
  late Timer _overlayTimer;

  /// Disposes the overlay reactions.
  late final ReactionDisposer _disposeOverlayReaction;

  /// The JavaScript channels used to communicate play/pause from the webview to Flutter.
  late final javascriptChannels = {
    JavascriptChannel(
      name: 'VideoPause',
      onMessageReceived: (message) {
        _paused = true;
        if (Platform.isAndroid) pip.setIsPlaying(false);
      },
    ),
    JavascriptChannel(
      name: 'VideoPlaying',
      onMessageReceived: (message) {
        _paused = false;
        if (Platform.isAndroid) pip.setIsPlaying(true);
        controller?.runJavascript('document.getElementsByTagName("video")[0].muted = false;');
        controller?.runJavascript('document.getElementsByTagName("video")[0].volume = 1.0;');
      },
    ),
  };

  /// Used for preventing accidental navigation in the webview.
  FutureOr<NavigationDecision> handleNavigation(NavigationRequest navigation) {
    if (navigation.url.startsWith('https://player.twitch.tv')) {
      return NavigationDecision.navigate;
    }
    return NavigationDecision.prevent;
  }

  /// If the video is currently paused.
  ///
  /// Does not pause or play the video, only used for rendering state of the overlay.
  @readonly
  var _paused = true;

  /// If the overlay is should be visible.
  @readonly
  var _overlayVisible = true;

  /// If the current device is iPad.
  @readonly
  var _isIPad = false;

  /// The current stream info, used for displaying relevant info on the overlay.
  @readonly
  StreamTwitch? _streamInfo;

  /// A map of stream qualities to their respective URLs for the current channel.
  @readonly
  Map<String, String>? _streamLinks;

  @readonly
  var _selectedQuality = '';

  /// The video URL to use for the webview. Controls will be disabled when custom overlay is enabled.
  @computed
  String get videoUrl => settingsStore.showOverlay
      ? 'https://player.twitch.tv/?channel=$userLogin&controls=false&muted=false&parent=frosty'
      : 'https://player.twitch.tv/?channel=$userLogin&muted=false&parent=frosty';

  VideoStoreBase({
    required this.userLogin,
    required this.twitchApi,
    required this.authStore,
    required this.settingsStore,
  }) {
    // On Android, enable auto PiP mode (setAutoEnterEnabled) if the device supports it.
    if (Platform.isAndroid) {
      SimplePip.isAutoPipAvailable.then((isAutoPipAvailable) {
        if (isAutoPipAvailable) pip.setAutoPipMode();
      });
    }

    // Initialize the [_overlayTimer] to hide the overlay automatically after 5 seconds.
    _overlayTimer = Timer(const Duration(seconds: 5), () => _overlayVisible = false);

    // Initialize a reaction that will reload the webview whenever the overlay is toggled.
    _disposeOverlayReaction = reaction(
      (_) => settingsStore.showOverlay,
      (_) => controller?.loadUrl(videoUrl),
    );

    updateStreamInfo();
  }

  Future<VideoPlayerController> createVideoPlayerController(String url) async {
    final controller = VideoPlayerController.network(
      url,
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );

    controller.addListener(() {
      if (_videoPlayerController?.value.isPlaying == true) {
        _paused = false;
      } else {
        _paused = true;
      }
    });

    await controller.initialize();

    return controller;
  }

  /// Initializes the video webview.
  @action
  Future<void> initVideo() async {
    if (settingsStore.useNativePlayer) {
      _streamLinks = await twitchApi.getStreamLinks(userLogin: userLogin, token: authStore.streamLinkToken);

      SplayTreeMap<String, String> sortedStreamLinks = SplayTreeMap<String, String>(
        (a, b) => int.parse(b.split('p').first).compareTo(int.parse(a.split('p').first)),
      );
      sortedStreamLinks.addAll(_streamLinks!);
      _streamLinks = sortedStreamLinks;

      _selectedQuality = _streamLinks!.keys.first;
      _videoPlayerController = await createVideoPlayerController(_streamLinks?[_selectedQuality] ?? '');
    } else {
      // Add event listeners to notify the JavaScript channels when the video plays and pauses.
      try {
        controller?.runJavascript(
            'document.getElementsByTagName("video")[0].addEventListener("pause", () => VideoPause.postMessage("video paused"));');
        controller?.runJavascript(
            'document.getElementsByTagName("video")[0].addEventListener("playing", () => VideoPlaying.postMessage("video playing"));');
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    // Determine whether the device is an iPad or not.
    // Used to show or hide the rotate button on the overlay.
    // Flutter doesn't allow programmatic rotation on iPad unless multitasking is disabled.
    if (Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      final info = await deviceInfo.iosInfo;
      if (info.model?.toLowerCase().contains('ipad') == true) {
        _isIPad = true;
      } else {
        _isIPad = false;
      }
    }
  }

  @action
  Future<void> handleQualityChange(String quality) async {
    await _videoPlayerController?.dispose();

    _videoPlayerController = await createVideoPlayerController(_streamLinks?[_selectedQuality] ?? '');

    _selectedQuality = quality;
  }

  /// Called whenever the video/overlay is tapped.
  @action
  void handleVideoTap() {
    _overlayTimer.cancel();

    if (_overlayVisible) {
      _overlayVisible = false;
    } else {
      updateStreamInfo();

      _overlayVisible = true;
      _overlayTimer = Timer(const Duration(seconds: 5), () => _overlayVisible = false);
    }
  }

  /// Updates the stream info from the Twitch API.
  @action
  Future<void> updateStreamInfo() async {
    try {
      _streamInfo = await twitchApi.getStream(userLogin: userLogin, headers: authStore.headersTwitch);
    } catch (e) {
      debugPrint(e.toString());

      // If the stream is offline or if there is an error, disable the overlay.
      _overlayTimer.cancel();
      _streamInfo = null;
      _paused = true;
    }
  }

  /// Handles the toggle overlay options.
  ///
  /// The toggle overlay option allows switching between the custom and Twitch's overlay by long-pressing the overlay.
  @action
  void handleToggleOverlay() {
    if (settingsStore.toggleableOverlay) {
      HapticFeedback.mediumImpact();

      settingsStore.showOverlay = !settingsStore.showOverlay;

      if (settingsStore.showOverlay) {
        _overlayVisible = true;

        _overlayTimer.cancel();
        _overlayTimer = Timer(const Duration(seconds: 3), () => _overlayVisible = false);
      }
    }
  }

  /// Refreshes the stream webview and updates the stream info.
  @action
  void handleRefresh() {
    HapticFeedback.lightImpact();
    controller?.reload();
    updateStreamInfo();
  }

  /// Play or pause the video depending on the current state of [_paused].
  void handlePausePlay() {
    try {
      if (_paused) {
        _videoPlayerController?.play();

        controller?.runJavascript('document.getElementsByTagName("video")[0].play();');
      } else {
        _videoPlayerController?.pause();

        controller?.runJavascript('document.getElementsByTagName("video")[0].pause();');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Initiate picture in picture if available.
  ///
  /// On Android, this will utilize the native Android PiP API.
  /// On iOS, this will utilize the web picture-in-picture API.
  void requestPictureInPicture() {
    try {
      if (Platform.isAndroid) {
        pip.enterPipMode(autoEnter: true);
      } else if (Platform.isIOS) {
        controller?.runJavascript('document.getElementsByTagName("video")[0].requestPictureInPicture();');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @action
  void dispose() {
    // Disable auto PiP when leaving so that we don't enter PiP on other screens.
    if (Platform.isAndroid) {
      SimplePip.isAutoPipAvailable.then((isAutoPipAvailable) {
        if (isAutoPipAvailable) pip.setAutoPipMode(autoEnter: false);
      });
    }

    // Not ideal, but seems like the only way of disposing of the video properly.
    // Will both prevent the video from continuing to play when dismissed and closes PiP on iOS.
    if (Platform.isIOS) controller?.reload();

    _videoPlayerController?.dispose();

    _disposeOverlayReaction();
  }
}

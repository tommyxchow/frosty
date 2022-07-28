import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'video_store.g.dart';

class VideoStore = VideoStoreBase with _$VideoStore;

abstract class VideoStoreBase with Store {
  final TwitchApi twitchApi;

  /// The userlogin of the current channel.
  final String userLogin;

  final AuthStore authStore;

  final SettingsStore settingsStore;

  /// The [Floating] instance used for initiating PiP on Android.
  final floating = Floating();

  /// The webview controller used for injecting JavaScript to control the webview and video player.
  WebViewController? controller;

  /// The current timer for the sleep timer if active.
  Timer? sleepTimer;

  /// The timer that handles hiding the overlay automatically
  late Timer _overlayTimer;

  /// Disposes the overlay reactions.
  late final ReactionDisposer _disposeOverlayReaction;

  /// The JavaScript channels used to communicate play/pause from the webview to Flutter.
  late final javascriptChannels = {
    JavascriptChannel(
      name: 'VideoPause',
      onMessageReceived: (message) => _paused = true,
    ),
    JavascriptChannel(
      name: 'VideoPlaying',
      onMessageReceived: (message) {
        _paused = false;
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

  /// The amount of hours the sleep timer is set to.
  @observable
  var sleepHours = 0;

  /// The amount of minutes the sleep timer is set to.
  @observable
  var sleepMinutes = 0;

  /// The time remaining for the sleep timer.
  @observable
  var timeRemaining = const Duration();

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
    // Initialize the [_overlayTimer] to hide the overlay automatically after 5 seconds.
    _overlayTimer = Timer(const Duration(seconds: 5), () => _overlayVisible = false);

    // Initialize a reaction that will reload the webview whenever the overlay is toggled.
    _disposeOverlayReaction = reaction(
      (_) => settingsStore.showOverlay,
      (_) => controller?.loadUrl(videoUrl),
    );

    updateStreamInfo();
  }

  /// Initializes the video webview.
  @action
  Future<void> initVideo() async {
    // Add event listeners to notify the JavaScript channels when the video plays and pauses.
    try {
      controller?.runJavascript('document.getElementsByTagName("video")[0].addEventListener("pause", () => VideoPause.postMessage("video paused"));');
      controller?.runJavascript('document.getElementsByTagName("video")[0].addEventListener("playing", () => VideoPlaying.postMessage("video playing"));');
    } catch (e) {
      debugPrint(e.toString());
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
  ///
  /// If the stream is offline, disables the overlay.
  @action
  Future<void> updateStreamInfo() async {
    try {
      _streamInfo = await twitchApi.getStream(userLogin: userLogin, headers: authStore.headersTwitch);
    } catch (e) {
      debugPrint(e.toString());

      _overlayTimer.cancel();
      _streamInfo = null;
      _paused = true;
    }
  }

  /// Handles toggling "minimal mode" on the overlay.
  ///
  /// "Minimal mode" is when only the channel name is visible on the bottom-left of the overlay.
  @action
  void handleExpand() {
    settingsStore.expandInfo = !settingsStore.expandInfo;

    _overlayTimer.cancel();
    _overlayTimer = Timer(const Duration(seconds: 5), () => _overlayVisible = false);
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

  /// Updates the sleep timer with [sleepHours] and [sleepMinutes].
  /// Calls [onTimerFinished] when the sleep timer completes.
  @action
  void updateSleepTimer({required void Function() onTimerFinished}) {
    // If hours and minutes are 0, do nothing.
    if (sleepHours == 0 && sleepMinutes == 0) return;

    // If there is an ongoing timer, cancel it since it'll be replaced.
    if (sleepTimer != null) cancelSleepTimer();

    // Update the new time remaining
    timeRemaining = Duration(hours: sleepHours, minutes: sleepMinutes);

    // Reset the hours and minutes in the dropdown buttons.
    sleepHours = 0;
    sleepMinutes = 0;

    // Set a periodic timer that will update the time remaining every second.
    sleepTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        // If the timer is up, cancel the timer and exit the app.
        if (timeRemaining.inSeconds == 0) {
          timer.cancel();
          onTimerFinished();
          return;
        }

        // Decrement the time remaining.
        timeRemaining = Duration(seconds: timeRemaining.inSeconds - 1);
      },
    );
  }

  /// Cancels the sleep timer and resets the time remaining.
  @action
  void cancelSleepTimer() {
    sleepTimer?.cancel();
    timeRemaining = const Duration();
  }

  /// Play or pause the video depending on the current state of [_paused].
  void handlePausePlay() {
    try {
      if (_paused) {
        controller?.runJavascript('document.getElementsByTagName("video")[0].play();');
      } else {
        controller?.runJavascript('document.getElementsByTagName("video")[0].pause();');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Initiate picture in picture if available.
  ///
  /// On iOS, this will utilize the web picture-in-picture API.
  /// On Android, this will utilize the native Android PiP API.
  void requestPictureInPicture() {
    try {
      if (Platform.isAndroid) {
        floating.enable();
      } else if (Platform.isIOS) {
        controller?.runJavascript('document.getElementsByTagName("video")[0].requestPictureInPicture();');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @action
  void dispose() {
    controller?.runJavascript('document.getElementsByTagName("video")[0].pause();');
    _disposeOverlayReaction();
    floating.dispose();
    sleepTimer?.cancel();
  }
}

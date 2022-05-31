import 'dart:async';

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

  WebViewController? controller;

  late Timer _overlayTimer;

  Timer? sleepTimer;

  @observable
  var sleepHours = 0;

  @observable
  var sleepMinutes = 0;

  @observable
  var timeRemaining = const Duration();

  @readonly
  var _paused = true;

  @readonly
  var _overlayVisible = true;

  @readonly
  StreamTwitch? _streamInfo;

  @computed
  String get videoUrl => settingsStore.showOverlay
      ? 'https://player.twitch.tv/?channel=$userLogin&controls=false&muted=false&parent=frosty'
      : 'https://player.twitch.tv/?channel=$userLogin&muted=false&parent=frosty';

  late final javascriptChannels = {
    JavascriptChannel(
      name: 'Pause',
      onMessageReceived: (message) => _paused = true,
    ),
    JavascriptChannel(
      name: 'Play',
      onMessageReceived: (message) {
        _paused = false;
        controller?.runJavascript('document.getElementsByTagName("video")[0].muted = false;');
      },
    ),
  };

  final String userLogin;
  final AuthStore authStore;
  final SettingsStore settingsStore;

  VideoStoreBase({
    required this.userLogin,
    required this.twitchApi,
    required this.authStore,
    required this.settingsStore,
  }) {
    _overlayTimer = Timer(const Duration(seconds: 3), () => _overlayVisible = false);
    updateStreamInfo();
  }

  @action
  void handlePausePlay() {
    try {
      if (_paused) {
        controller?.runJavascript('document.getElementsByTagName("video")[0].play();');
        controller?.runJavascript('document.getElementsByTagName("video")[0].muted = false;');
      } else {
        controller?.runJavascript('document.getElementsByTagName("video")[0].pause();');
      }

      _paused = !_paused;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

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

  @action
  void handleExpand() {
    settingsStore.expandInfo = !settingsStore.expandInfo;

    _overlayTimer.cancel();
    _overlayTimer = Timer(const Duration(seconds: 5), () => _overlayVisible = false);
  }

  @action
  Future<void> handleToggleOverlay() async {
    if (settingsStore.toggleableOverlay) {
      settingsStore.showOverlay = !settingsStore.showOverlay;

      await controller?.loadUrl(videoUrl);

      if (settingsStore.showOverlay) {
        _overlayVisible = true;

        _overlayTimer.cancel();
        _overlayTimer = Timer(const Duration(seconds: 3), () => _overlayVisible = false);
      }
    }
  }

  void handleRefresh() {
    HapticFeedback.lightImpact();
    controller?.reload();
  }

  FutureOr<NavigationDecision> handleNavigation(NavigationRequest navigation) {
    if (navigation.url.startsWith('https://player.twitch.tv')) {
      return NavigationDecision.navigate;
    }
    return NavigationDecision.prevent;
  }

  void initVideo() {
    try {
      controller?.runJavascript('document.getElementsByTagName("video")[0].addEventListener("pause", () => Pause.postMessage("video paused"));');
      controller?.runJavascript('document.getElementsByTagName("video")[0].addEventListener("play", () => Play.postMessage("video playing"));');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void requestPictureInPicture() {
    try {
      controller?.runJavascript('document.getElementsByTagName("video")[0].requestPictureInPicture();');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Updates the sleep timer with [sleepHours] and [sleepMinutes].
  /// Calls [onTimerFinished] when the sleep timer completes.
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
  void cancelSleepTimer() {
    sleepTimer?.cancel();
    timeRemaining = const Duration();
  }
}

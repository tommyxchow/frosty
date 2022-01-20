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

class VideoStore = _VideoStoreBase with _$VideoStore;

abstract class _VideoStoreBase with Store {
  final TwitchApi twitchApi;

  WebViewController? controller;

  late Timer overlayTimer;
  late Timer updateTimer;

  @readonly
  var _overlayVisible = true;

  @observable
  var paused = true;

  @readonly
  StreamTwitch? _streamInfo;

  final String userLogin;
  final AuthStore authStore;
  final SettingsStore settingsStore;

  _VideoStoreBase({
    required this.twitchApi,
    required this.userLogin,
    required this.authStore,
    required this.settingsStore,
  }) {
    overlayTimer = Timer(const Duration(seconds: 3), () => _overlayVisible = false);
    updateStreamInfo();
  }

  @action
  void handlePausePlay() {
    try {
      if (paused) {
        controller?.runJavascript('document.getElementsByTagName("video")[0].play();');
      } else {
        controller?.runJavascript('document.getElementsByTagName("video")[0].pause();');
      }

      paused = !paused;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @action
  void handleVideoTap() {
    if (_overlayVisible) {
      overlayTimer.cancel();

      _overlayVisible = false;
    } else {
      overlayTimer.cancel();
      overlayTimer = Timer(const Duration(seconds: 5), () => _overlayVisible = false);

      _overlayVisible = true;

      updateStreamInfo();
    }
  }

  @action
  Future<void> updateStreamInfo() async {
    try {
      final updatedStreamInfo = await twitchApi.getStream(userLogin: userLogin, headers: authStore.headersTwitch);
      _streamInfo = updatedStreamInfo;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @action
  void handleExpand() {
    overlayTimer.cancel();
    settingsStore.expandInfo = !settingsStore.expandInfo;
    overlayTimer = Timer(const Duration(seconds: 5), () => _overlayVisible = false);
  }

  void handleRefresh() async {
    HapticFeedback.lightImpact();
    controller?.reload();
  }

  void initVideo() {
    try {
      controller?.runJavascript('document.getElementsByTagName("video")[0].addEventListener("pause", () => Pause.postMessage("video paused"));');
      controller?.runJavascript('document.getElementsByTagName("video")[0].addEventListener("play", () => Play.postMessage("video playing"));');
      controller?.runJavascript('document.getElementsByTagName("video")[0].muted = false;');
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
}

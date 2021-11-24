import 'dart:async';
import 'dart:io';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/stream.dart';
import 'package:mobx/mobx.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'video_store.g.dart';

class VideoStore = _VideoStoreBase with _$VideoStore;

abstract class _VideoStoreBase with Store {
  late final WebViewController controller;

  late Timer timer;

  @observable
  var menuVisible = true;

  @observable
  var paused = false;

  @observable
  StreamTwitch? streamInfo;

  final String userLogin;

  final AuthStore authStore;

  _VideoStoreBase({required this.userLogin, required this.authStore}) {
    timer = Timer(const Duration(seconds: 3), () => menuVisible = false);
    updateStreamInfo();
  }

  @action
  void handlePausePlay() {
    if (paused) {
      controller.runJavascript('document.getElementsByTagName("video")[0].play();');
    } else {
      controller.runJavascript('document.getElementsByTagName("video")[0].pause();');
    }

    paused = !paused;
  }

  @action
  void handleVideoTap() {
    if (menuVisible) {
      timer.cancel();

      menuVisible = false;
    } else {
      timer.cancel();
      timer = Timer(const Duration(seconds: 5), () {
        menuVisible = false;
      });

      menuVisible = true;
      updateStreamInfo();
    }
  }

  @action
  Future<void> updateStreamInfo() async {
    final updatedStreamInfo = await Twitch.getStream(userLogin: userLogin, headers: authStore.headersTwitch);
    if (updatedStreamInfo != null) {
      streamInfo = updatedStreamInfo;
    }
  }

  void initVideo() {
    controller.runJavascript('document.getElementsByTagName("button")[0].click();');
    controller.runJavascript('document.getElementsByTagName("video")[0].muted = false;');
  }

  void enterPictureInPicture() {
    controller.runJavascript('document.getElementsByTagName("video")[0].disablePictureInPicture = false;');
    controller.runJavascript('document.getElementsByTagName("video")[0].requestPictureInPicture();');
  }

  void requestFullscreen() {
    Platform.isIOS
        ? controller.runJavascript('document.getElementsByTagName("video")[0].webkitEnterFullscreen();')
        : controller.runJavascript('document.getElementsByTagName("video")[0].requestFullscreen();');
  }
}

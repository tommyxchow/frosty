import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'video_store.g.dart';

class VideoStore = _VideoStoreBase with _$VideoStore;

abstract class _VideoStoreBase with Store {
  late final WebViewController controller;

  late Timer timer;

  _VideoStoreBase() {
    timer = Timer(const Duration(seconds: 3), () => menuVisible = false);
  }

  @observable
  var menuVisible = true;

  @observable
  var paused = false;

  void handlePausePlay() {
    if (paused) {
      controller.runJavascript('document.getElementsByTagName("video")[0].play();');
    } else {
      controller.runJavascript('document.getElementsByTagName("video")[0].pause();');
    }

    paused = !paused;
  }

  void handleVideoTap() async {
    if (menuVisible) {
      timer.cancel();

      menuVisible = false;
    } else {
      timer.cancel();
      timer = Timer(const Duration(seconds: 5), () {
        debugPrint('timer thing');
        menuVisible = false;
      });

      menuVisible = true;
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
    controller.runJavascript('document.getElementsByTagName("video")[0].requestFullscreen();');
    controller.runJavascript('document.getElementsByTagName("video")[0].webkitEnterFullscreen();');
  }
}

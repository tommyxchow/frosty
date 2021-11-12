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
    timer = Timer(const Duration(seconds: 5), () => menuVisible = false);
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

  void removeOverlay() {
    controller.runJavascript('document.getElementsByClassName("video-player__overlay")[0].innerHTML = "";');
  }

  void requestFullscreen() {
    controller.runJavascript('document.getElementsByTagName("video")[0].requestFullscreen()');
  }
}

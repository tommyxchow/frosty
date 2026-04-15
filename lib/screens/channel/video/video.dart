import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Creates a [WebView] widget that shows a channel's video stream.
class Video extends StatefulWidget {
  final VideoStore videoStore;

  const Video({super.key, required this.videoStore});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (widget.videoStore.settingsStore.showVideo) {
      widget.videoStore.videoWebViewController.loadRequest(
        Uri.parse(widget.videoStore.videoUrl),
      );
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(
    AppLifecycleState lifecycleState,
  ) async {
    if (!widget.videoStore.settingsStore.showVideo) return;

    // On Android, manually enter Picture-in-Picture if auto isn't available.
    // On iOS, auto Picture-in-Picture is handled by the video element's
    // autopictureinpicture attribute set in initVideo().
    if (lifecycleState == AppLifecycleState.inactive &&
        Platform.isAndroid &&
        !await SimplePip.isAutoPipAvailable) {
      widget.videoStore.requestPictureInPicture();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: widget.videoStore.videoWebViewController.platform,
          displayWithHybridComposition:
              !widget.videoStore.settingsStore.useTextureRendering,
        ),
      );
    } else {
      return WebViewWidget(
        controller: widget.videoStore.videoWebViewController,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.videoStore.videoWebViewController.loadRequest(
      Uri.parse('about:blank'),
    );

    super.dispose();
  }
}

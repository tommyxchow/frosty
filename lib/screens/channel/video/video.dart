import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Creates a [WebView] widget that shows a channel's video stream.
class Video extends StatefulWidget {
  final VideoStore videoStore;

  const Video({
    Key? key,
    required this.videoStore,
  }) : super(key: key);

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (widget.videoStore.settingsStore.showVideo) {
      widget.videoStore.videoWebViewController
          .loadRequest(Uri.parse(widget.videoStore.videoUrl));
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(
    AppLifecycleState lifecycleState,
  ) async {
    if (Platform.isAndroid &&
        !await SimplePip.isAutoPipAvailable &&
        lifecycleState == AppLifecycleState.inactive) {
      widget.videoStore.requestPictureInPicture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: widget.videoStore.videoWebViewController,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.videoStore.videoWebViewController
        .loadRequest(Uri.parse('about:blank'));

    super.dispose();
  }
}

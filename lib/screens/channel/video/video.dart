import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (Platform.isAndroid && lifecycleState == AppLifecycleState.inactive) {
      widget.videoStore.requestPictureInPicture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      backgroundColor: Colors.black,
      initialUrl: widget.videoStore.videoUrl,
      javascriptMode: JavascriptMode.unrestricted,
      allowsInlineMediaPlayback: true,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      onWebViewCreated: (controller) => widget.videoStore.controller = controller,
      onPageFinished: (string) => widget.videoStore.initVideo(),
      navigationDelegate: widget.videoStore.handleNavigation,
      javascriptChannels: widget.videoStore.javascriptChannels,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

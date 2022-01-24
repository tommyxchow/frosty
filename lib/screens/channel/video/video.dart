import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/stores/video_store.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Video extends StatelessWidget {
  final VideoStore videoStore;

  const Video({
    Key? key,
    required this.videoStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebView(
      backgroundColor: Colors.black,
      initialUrl: videoStore.videoUrl,
      javascriptMode: JavascriptMode.unrestricted,
      allowsInlineMediaPlayback: true,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      onWebViewCreated: (controller) => videoStore.controller = controller,
      onPageFinished: (string) => videoStore.initVideo(),
      navigationDelegate: videoStore.handleNavigation,
      javascriptChannels: videoStore.javascriptChannels,
    );
  }
}

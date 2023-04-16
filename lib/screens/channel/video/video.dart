import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) async {
    if (Platform.isAndroid && !await SimplePip.isAutoPipAvailable && lifecycleState == AppLifecycleState.inactive) {
      widget.videoStore.requestPictureInPicture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (widget.videoStore.settingsStore.useNativePlayer) return NativeVideo(videoStore: widget.videoStore);

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
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// Creates a [WebView] widget that shows a channel's video stream.
class WebVideo extends StatefulWidget {
  final VideoStore videoStore;

  const WebVideo({
    Key? key,
    required this.videoStore,
  }) : super(key: key);

  @override
  State<WebVideo> createState() => _WebVideoState();
}

class _WebVideoState extends State<WebVideo> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) async {
    if (Platform.isAndroid && !await SimplePip.isAutoPipAvailable && lifecycleState == AppLifecycleState.inactive) {
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

class NativeVideo extends StatefulWidget {
  final VideoStore videoStore;

  const NativeVideo({
    Key? key,
    required this.videoStore,
  }) : super(key: key);

  @override
  State<NativeVideo> createState() => _NativeVideoState();
}

class _NativeVideoState extends State<NativeVideo> {
  @override
  void initState() {
    super.initState();
    widget.videoStore.initVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final videoPlayerController = widget.videoStore.videoPlayerController;

        if (widget.videoStore.streamLinks == null || videoPlayerController == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(controller: videoPlayerController),
          ),
        );
      },
    );
  }
}

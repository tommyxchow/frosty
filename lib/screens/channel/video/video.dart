import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/channel/video/video_overlay.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Video extends StatelessWidget {
  final String userLogin;
  final String userName;
  final String title;
  final VideoStore videoStore;

  const Video({
    Key? key,
    required this.title,
    required this.userName,
    required this.userLogin,
    required this.videoStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (context.read<SettingsStore>().overlayEnabled) {
          return Stack(
            children: [
              WebView(
                initialUrl: 'https://player.twitch.tv/?channel=$userLogin&controls=false&muted=false&parent=frosty',
                javascriptMode: JavascriptMode.unrestricted,
                allowsInlineMediaPlayback: true,
                initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                onWebViewCreated: (controller) {
                  videoStore.controller = controller;
                },
                onPageFinished: (string) {
                  videoStore.initVideo();
                },
              ),
              VideoOverlay(
                title: title,
                userName: userName,
                videoStore: videoStore,
              ),
            ],
          );
        } else {
          return WebView(
            initialUrl: 'https://player.twitch.tv/?channel=$userLogin&muted=false&parent=frosty',
            javascriptMode: JavascriptMode.unrestricted,
            allowsInlineMediaPlayback: true,
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          );
        }
      },
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/video/video_overlay.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Video extends StatelessWidget {
  final String userLogin;
  final VideoStore videoStore;

  const Video({
    Key? key,
    required this.userLogin,
    required this.videoStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Observer(
        builder: (context) {
          if (videoStore.settingsStore.showOverlay) {
            return Stack(
              children: [
                WebView(
                  initialUrl: 'https://player.twitch.tv/?channel=$userLogin&controls=false&muted=false&parent=frosty',
                  javascriptMode: JavascriptMode.unrestricted,
                  allowsInlineMediaPlayback: true,
                  initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                  onWebViewCreated: (controller) => videoStore.controller = controller,
                  onPageFinished: (string) => videoStore.initVideo(),
                ),
                VideoOverlay(videoStore: videoStore),
              ],
            );
          }
          return WebView(
            initialUrl: 'https://player.twitch.tv/?channel=$userLogin&muted=false&parent=frosty',
            javascriptMode: JavascriptMode.unrestricted,
            allowsInlineMediaPlayback: true,
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          );
        },
      ),
    );
  }
}

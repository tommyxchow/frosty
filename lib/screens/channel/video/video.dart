import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/stores/video_store.dart';
import 'package:frosty/screens/channel/video/video_overlay.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Video extends StatelessWidget {
  final String userLogin;
  final FocusNode textFieldFocus;
  final VideoStore videoStore;

  const Video({
    Key? key,
    required this.userLogin,
    required this.textFieldFocus,
    required this.videoStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => GestureDetector(
        onLongPress:
            videoStore.settingsStore.toggleableOverlay ? () => videoStore.settingsStore.showOverlay = !videoStore.settingsStore.showOverlay : null,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Observer(
            builder: (context) {
              if (videoStore.settingsStore.showOverlay) {
                return Stack(
                  children: [
                    WebView(
                      backgroundColor: Colors.black,
                      initialUrl: 'https://player.twitch.tv/?channel=$userLogin&controls=false&muted=false&parent=frosty',
                      javascriptMode: JavascriptMode.unrestricted,
                      allowsInlineMediaPlayback: true,
                      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                      onWebViewCreated: (controller) => videoStore.controller = controller,
                      onPageFinished: (string) => videoStore.initVideo(),
                      navigationDelegate: (navigation) {
                        if (navigation.url.startsWith('https://player.twitch.tv')) {
                          return NavigationDecision.navigate;
                        }
                        return NavigationDecision.prevent;
                      },
                      javascriptChannels: {
                        JavascriptChannel(
                          name: 'Pause',
                          onMessageReceived: (message) {
                            videoStore.paused = true;
                          },
                        ),
                        JavascriptChannel(
                          name: 'Play',
                          onMessageReceived: (message) {
                            videoStore.paused = false;
                          },
                        ),
                      },
                    ),
                    Observer(
                      builder: (_) {
                        if (videoStore.paused) return VideoOverlay(videoStore: videoStore);
                        return SizedBox.expand(
                          child: Observer(
                            builder: (_) => AnimatedOpacity(
                              opacity: videoStore.overlayVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: ColoredBox(
                                color: const Color.fromRGBO(0, 0, 0, 0.5),
                                child: IgnorePointer(
                                  ignoring: !videoStore.overlayVisible,
                                  child: VideoOverlay(videoStore: videoStore),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                );
              }
              return WebView(
                backgroundColor: Colors.black,
                initialUrl: 'https://player.twitch.tv/?channel=$userLogin&muted=false&parent=frosty',
                javascriptMode: JavascriptMode.unrestricted,
                allowsInlineMediaPlayback: true,
                initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                navigationDelegate: (navigation) {
                  if (navigation.url.startsWith('https://player.twitch.tv')) {
                    return NavigationDecision.navigate;
                  }
                  return NavigationDecision.prevent;
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

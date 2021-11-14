import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings.dart';
import 'package:frosty/stores/settings_store.dart';
import 'package:frosty/stores/video_store.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Video extends StatelessWidget {
  final String userLogin;
  final String userName;
  final VideoStore videoStore;
  final SettingsStore settingsStore;

  const Video({
    Key? key,
    required this.userLogin,
    required this.userName,
    required this.videoStore,
    required this.settingsStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebView(
          initialUrl: 'https://player.twitch.tv/?channel=$userLogin&muted=false&parent=frosty',
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
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: SizedBox.expand(
            child: Observer(
              builder: (_) {
                return AnimatedOpacity(
                  opacity: videoStore.menuVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: ColoredBox(
                    color: Colors.black.withOpacity(0.5),
                    child: Visibility(
                      visible: videoStore.menuVisible,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Settings(settingsStore: settingsStore);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            icon: videoStore.paused
                                ? const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.pause,
                                    color: Colors.white,
                                  ),
                            onPressed: videoStore.handlePausePlay,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                ),
                                onPressed: videoStore.requestFullscreen,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          onTap: videoStore.handleVideoTap,
        ),
      ],
    );
  }
}

import 'package:better_native_video_player/better_native_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/video/native_video_store.dart';

/// Native video player widget backed by AVPlayerViewController (iOS)
/// and ExoPlayer (Android).
class NativeVideo extends StatelessWidget {
  final NativeVideoStore nativeVideoStore;

  const NativeVideo({super.key, required this.nativeVideoStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final controller = nativeVideoStore.controller;
        final error = nativeVideoStore.error;

        final isOffline =
            !nativeVideoStore.loading &&
            nativeVideoStore.streamInfo == null &&
            error == null;

        return ColoredBox(
          color: Colors.black,
          child: Stack(
            children: [
              if (controller != null && !isOffline)
                NativeVideoPlayer(
                  key: ObjectKey(controller),
                  controller: controller,
                ),
              if (controller != null && !nativeVideoStore.hasPlayedOnce && !isOffline)
                const ColoredBox(
                  color: Colors.black,
                  child: SizedBox.expand(),
                ),
              if (error != null)
                Align(
                  alignment: const Alignment(0, 0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.amber.withValues(alpha: 0.7),
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          error,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              if (isOffline)
                const Center(
                  child: Icon(
                    Icons.tv_off_rounded,
                    color: Colors.white24,
                    size: 32,
                  ),
                ),
              if (nativeVideoStore.isAudioOnlyMode && !isOffline)
                const ColoredBox(
                  color: Colors.black,
                  child: SizedBox.expand(
                    child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.headphones_rounded,
                          color: Colors.white24,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Audio Only',
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

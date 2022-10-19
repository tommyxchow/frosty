import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/video/video.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:frosty/screens/home/home_store.dart';
import 'package:provider/provider.dart';

import '../../../apis/twitch_api.dart';
import '../../../models/stream.dart';
import '../../../widgets/animate_scale.dart';
import '../../settings/stores/auth_store.dart';
import '../../settings/stores/settings_store.dart';
import '../channel.dart';

class CollapsedVideoPlayer extends StatefulWidget {
  final HomeStore homeStore;
  const CollapsedVideoPlayer({Key? key, required this.homeStore}) : super(key: key);

  @override
  State<CollapsedVideoPlayer> createState() => _CollapsedVideoPlayerState();
}

class _CollapsedVideoPlayerState extends State<CollapsedVideoPlayer> {
  final _videoKey = GlobalKey();

  late final VideoStore _videoStore = VideoStore(
    userLogin: widget.homeStore.userLogin,
    twitchApi: context.read<TwitchApi>(),
    authStore: context.read<AuthStore>(),
    settingsStore: context.read<SettingsStore>(),
  );

  @override
  Widget build(BuildContext context) {

    return AnimateScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoChat(
              userId: widget.homeStore.userId,
              userName: widget.homeStore.userName,
              userLogin: widget.homeStore.userLogin,
              homeStore: widget.homeStore,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 500,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: IgnorePointer(
            child: Video(
              key: _videoKey,
              videoStore: _videoStore,
            ),
          ),
        ),
      ),
    );
  }
}

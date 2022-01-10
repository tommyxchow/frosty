import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/screens/channel/stores/video_store.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a stream's thumbnail and details.
class StreamCard extends StatelessWidget {
  final StreamTwitch streamInfo;
  final bool showUptime;

  const StreamCard({
    Key? key,
    required this.streamInfo,
    required this.showUptime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumbnail = CachedNetworkImage(
      imageUrl: streamInfo.thumbnailUrl.replaceFirst('-{width}x{height}', '-440x248') + (DateTime.now().minute ~/ 5).toString(),
      useOldImageOnUrlChange: true,
    );

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoChat(
            displayName: streamInfo.userName,
            videoStore: VideoStore(
              userLogin: streamInfo.userLogin,
              authStore: context.read<AuthStore>(),
              settingsStore: context.read<SettingsStore>(),
            ),
            chatStore: ChatStore(
              channelName: streamInfo.userLogin,
              auth: context.read<AuthStore>(),
              settings: context.read<SettingsStore>(),
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: showUptime
                  ? Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        thumbnail,
                        Container(
                          color: const Color.fromRGBO(0, 0, 0, 0.5),
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text(
                            DateTime.now().difference(DateTime.parse(streamInfo.startedAt)).toString().split('.')[0],
                            style: const TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)),
                          ),
                        )
                      ],
                    )
                  : thumbnail,
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProfilePicture(
                          userLogin: streamInfo.userLogin,
                          radius: 10.0,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          streamInfo.userName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    Tooltip(
                      message: streamInfo.title,
                      preferBelow: false,
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        streamInfo.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(streamInfo.gameName),
                    const SizedBox(height: 5.0),
                    Text(
                      '${NumberFormat().format(streamInfo.viewerCount)} viewers',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

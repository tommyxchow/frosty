import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/api/bttv_api.dart';
import 'package:frosty/api/ffz_api.dart';
import 'package:frosty/api/seventv_api.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/stores/chat_assets_store.dart';
import 'package:frosty/screens/channel/stores/chat_details_store.dart';
import 'package:frosty/screens/channel/stores/chat_store.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a stream's thumbnail and details.
class StreamCard extends StatelessWidget {
  final StreamTwitch streamInfo;
  final int width;
  final int height;
  final bool showUptime;

  const StreamCard({
    Key? key,
    required this.streamInfo,
    required this.width,
    required this.height,
    required this.showUptime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = DateTime.now();
    final cacheUrlExtension = time.day.toString() + time.hour.toString() + (time.minute ~/ 5).toString();

    final thumbnail = CachedNetworkImage(
      imageUrl: streamInfo.thumbnailUrl.replaceFirst('-{width}x{height}', '-${width}x$height') + cacheUrlExtension,
      useOldImageOnUrlChange: true,
    );

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoChat(
            chatStore: ChatStore(
              channelName: streamInfo.userLogin,
              channelId: streamInfo.userId,
              displayName: streamInfo.userName,
              auth: context.read<AuthStore>(),
              settings: context.read<SettingsStore>(),
              chatDetailsStore: ChatDetailsStore(
                twitchApi: context.read<TwitchApi>(),
              ),
              assetsStore: ChatAssetsStore(
                twitchApi: context.read<TwitchApi>(),
                ffzApi: context.read<FFZApi>(),
                bttvApi: context.read<BTTVApi>(),
                sevenTVApi: context.read<SevenTVApi>(),
              ),
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
                            style: const TextStyle(fontSize: 12, color: Colors.white),
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
                          regexEnglish.hasMatch(streamInfo.userName) ? streamInfo.userName : streamInfo.userName + ' (${streamInfo.userLogin})',
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/top/category_streams.dart';
import 'package:frosty/widgets/block_report_modal.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a stream's thumbnail and details.
class StreamCard extends StatelessWidget {
  final ListStore listStore;
  final StreamTwitch streamInfo;
  final int width;
  final int height;
  final bool showUptime;
  final bool showThumbnail;
  final bool showCategory;

  const StreamCard({
    Key? key,
    required this.listStore,
    required this.streamInfo,
    required this.width,
    required this.height,
    required this.showUptime,
    required this.showThumbnail,
    this.showCategory = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = DateTime.now();
    final cacheUrlExtension = time.day.toString() + time.hour.toString() + (time.minute ~/ 5).toString();

    final thumbnail = AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: streamInfo.thumbnailUrl.replaceFirst('-{width}x{height}', '-${width}x$height') + cacheUrlExtension,
        placeholder: (context, url) => const LoadingIndicator(),
        useOldImageOnUrlChange: true,
      ),
    );

    final streamerName = regexEnglish.hasMatch(streamInfo.userName) ? streamInfo.userName : streamInfo.userName + ' (${streamInfo.userLogin})';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoChat(
            userId: streamInfo.userId,
            userName: streamInfo.userName,
            userLogin: streamInfo.userLogin,
          ),
        ),
      ),
      onLongPress: () => showModalBottomSheet(
        context: context,
        builder: (context) => BlockReportModal(
          authStore: listStore.authStore,
          name: streamerName,
          userLogin: streamInfo.userLogin,
          userId: streamInfo.userId,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: showThumbnail ? 15.0 : 5.0),
        child: Row(
          children: [
            if (showThumbnail)
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
                        Flexible(
                          child: Tooltip(
                            message: streamerName,
                            preferBelow: false,
                            child: Text(
                              streamerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    Tooltip(
                      message: streamInfo.title.trim(),
                      preferBelow: false,
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        streamInfo.title.trim(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    if (showCategory) ...[
                      InkWell(
                        child: Tooltip(
                          message: streamInfo.gameName,
                          preferBelow: false,
                          child: Text(
                            streamInfo.gameName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: DefaultTextStyle.of(context).style.color?.withOpacity(0.8),
                            ),
                          ),
                        ),
                        onTap: () async {
                          final category = await context
                              .read<TwitchApi>()
                              .getCategory(headers: context.read<AuthStore>().headersTwitch, gameId: streamInfo.gameId);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryStreams(
                                listStore: ListStore(
                                  twitchApi: context.read<TwitchApi>(),
                                  authStore: context.read<AuthStore>(),
                                  listType: ListType.category,
                                  categoryInfo: category.data.first,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 5.0),
                    ],
                    Text(
                      '${NumberFormat().format(streamInfo.viewerCount)} viewers',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w300,
                        color: DefaultTextStyle.of(context).style.color?.withOpacity(0.8),
                      ),
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

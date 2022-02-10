import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/widgets/block_report_modal.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:intl/intl.dart';

/// A tappable card widget that displays a stream's thumbnail and details.
class StreamCard extends StatelessWidget {
  final ListStore listStore;
  final StreamTwitch streamInfo;
  final int width;
  final int height;
  final bool showUptime;

  const StreamCard({
    Key? key,
    required this.listStore,
    required this.streamInfo,
    required this.width,
    required this.height,
    required this.showUptime,
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
                        Flexible(
                          child: Tooltip(
                            message: streamerName,
                            preferBelow: false,
                            child: Text(
                              streamerName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

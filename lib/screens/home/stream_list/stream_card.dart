import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/main.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/channel.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/animate_scale.dart';
import 'package:frosty/widgets/block_report_modal.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a stream's thumbnail and details.
class StreamCard extends StatelessWidget {
  final StreamTwitch streamInfo;
  final bool showThumbnail;
  final bool showCategory;

  const StreamCard({
    Key? key,
    required this.streamInfo,
    required this.showThumbnail,
    this.showCategory = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get a new URL for the thumbnail every 5 minutes so that the image is updated on refresh.
    // This method adds a random value to the end of the URL to override the cached image.
    final time = DateTime.now();
    final cacheUrlExtension = time.day.toString() +
        time.hour.toString() +
        (time.minute ~/ 5).toString();

    // Calculate the width and height of the thumbnail based on the device width and the stream card size setting.
    // Constraint the resolution to 1920x1080 since that's the max resolution of the Twitch API.
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final thumbnailWidth = min((size.width * pixelRatio) ~/ 3, 1920);
    final thumbnailHeight = min((thumbnailWidth * (9 / 16)).toInt(), 1080);

    final thumbnail = AspectRatio(
      aspectRatio: 16 / 9,
      child: FrostyCachedNetworkImage(
        imageUrl: streamInfo.thumbnailUrl.replaceFirst(
                '-{width}x{height}', '-${thumbnailWidth}x$thumbnailHeight') +
            cacheUrlExtension,
        placeholder: (context, url) =>
            const ColoredBox(color: lightGray, child: LoadingIndicator()),
        useOldImageOnUrlChange: true,
      ),
    );

    final streamerName = regexEnglish.hasMatch(streamInfo.userName)
        ? streamInfo.userName
        : '${streamInfo.userName} (${streamInfo.userLogin})';

    const subFontSize = 14.0;

    final fontColor = DefaultTextStyle.of(context).style.color;

    final imageSection = ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            thumbnail,
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                borderRadius: BorderRadius.all(
                  Radius.circular(3.0),
                ),
              ),
              margin: const EdgeInsets.all(2.0),
              child: Uptime(
                startTime: streamInfo.startedAt,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ));

    final streamInfoSection = Padding(
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
                  message: 'Streamer: $streamerName',
                  preferBelow: false,
                  child: Text(
                    streamerName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: fontColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5.0),
          Tooltip(
            message: 'Title: ${streamInfo.title.trim()}',
            preferBelow: false,
            padding: const EdgeInsets.all(10.0),
            child: Text(
              streamInfo.title.trim(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: subFontSize,
                color: fontColor?.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          if (showCategory) ...[
            InkWell(
              onTap: streamInfo.gameName.isNotEmpty
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryStreams(
                            categoryName: streamInfo.gameName,
                            categoryId: streamInfo.gameId,
                          ),
                        ),
                      )
                  : null,
              child: Tooltip(
                message:
                    'Category: ${streamInfo.gameName.isNotEmpty ? streamInfo.gameName : 'None'}',
                preferBelow: false,
                child: Text(
                  streamInfo.gameName.isNotEmpty
                      ? streamInfo.gameName
                      : 'No Category',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subFontSize,
                    color: fontColor?.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5.0),
          ],
          Text(
            '${NumberFormat().format(streamInfo.viewerCount)} viewers',
            style: TextStyle(
              fontSize: subFontSize,
              color: fontColor?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );

    return AnimateScale(
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
      onLongPress: () {
        HapticFeedback.mediumImpact();

        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => BlockReportModal(
            authStore: context.read<AuthStore>(),
            name: streamerName,
            userLogin: streamInfo.userLogin,
            userId: streamInfo.userId,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 10.0, horizontal: showThumbnail ? 15.0 : 5.0),
        child: Row(
          children: [
            if (showThumbnail)
              Flexible(
                child: imageSection,
              ),
            Flexible(
              flex: 2,
              child: streamInfoSection,
            ),
          ],
        ),
      ),
    );
  }
}

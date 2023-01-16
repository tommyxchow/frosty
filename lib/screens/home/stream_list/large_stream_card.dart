import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/main.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/channel.dart';
import 'package:frosty/screens/channel/video/video_bar.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/animate_scale.dart';
import 'package:frosty/widgets/block_report_modal.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LargeStreamCard extends StatelessWidget {
  final StreamTwitch streamInfo;
  final bool showThumbnail;
  final bool showCategory;

  const LargeStreamCard({
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
    final cacheUrlExtension = time.day.toString() + time.hour.toString() + (time.minute ~/ 5).toString();

    // Calculate the width and height of the thumbnail based on the device width and the stream card size setting.
    // Constraint the resolution to 1920x1080 since that's the max resolution of the Twitch API.
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final thumbnailWidth = min((size.width * pixelRatio) ~/ 1, 1920);
    final thumbnailHeight = min((thumbnailWidth * (9 / 16)).toInt(), 1080);

    final thumbnail = ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.8, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: FrostyCachedNetworkImage(
                imageUrl:
                    streamInfo.thumbnailUrl.replaceFirst('-{width}x{height}', '-${thumbnailWidth}x$thumbnailHeight') +
                        cacheUrlExtension,
                placeholder: (context, url) => const ColoredBox(color: lightGray, child: LoadingIndicator()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 10,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Uptime(
                      startTime: streamInfo.startedAt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10.0),
                Row(
                  children: [
                    const HeroIcon(
                      HeroIcons.users,
                      size: 14,
                      color: Colors.white,
                      style: HeroIconStyle.solid,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      NumberFormat().format(streamInfo.viewerCount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );

    final streamerName = regexEnglish.hasMatch(streamInfo.userName)
        ? streamInfo.userName
        : '${streamInfo.userName} (${streamInfo.userLogin})';

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
        padding: EdgeInsets.symmetric(vertical: showThumbnail ? 10.0 : 5.0, horizontal: 15.0),
        child: Column(
          children: [
            if (showThumbnail) thumbnail,
            VideoBar(
              streamInfo: streamInfo,
              showCategory: showCategory,
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/channel.dart';
import 'package:frosty/screens/channel/video/video_bar.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:frosty/widgets/user_actions_modal.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LargeStreamCard extends StatelessWidget {
  final StreamTwitch streamInfo;
  final bool showThumbnail;
  final bool showCategory;
  final bool showPinOption;
  final bool? isPinned;

  const LargeStreamCard({
    super.key,
    required this.streamInfo,
    required this.showThumbnail,
    this.showCategory = true,
    this.showPinOption = false,
    this.isPinned,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a unique cache key for the thumbnail URL that updates every 5 minutes.
    // This ensures the image is refreshed periodically to reflect the latest content.
    final time = DateTime.now();
    final cacheKey =
        '${streamInfo.thumbnailUrl}-${time.day}-${time.hour}-${time.minute ~/ 5}';

    // Calculate the width and height of the thumbnail based on the device width and the stream card size setting.
    // Constraint the resolution to 1920x1080 since that's the max resolution of the Twitch API.
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final thumbnailWidth = min((size.width * pixelRatio) ~/ 1, 1920);
    final thumbnailHeight = min((thumbnailWidth * (9 / 16)).toInt(), 1080);
    final surfaceColor =
        context.watch<FrostyThemes>().dark.colorScheme.onSurface;

    final thumbnail = ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            foregroundDecoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.8, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black,
                ],
              ),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: FrostyCachedNetworkImage(
                imageUrl: streamInfo.thumbnailUrl.replaceFirst(
                  '-{width}x{height}',
                  '-${thumbnailWidth}x$thumbnailHeight',
                ),
                cacheKey: cacheKey,
                placeholder: (context, url) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: const LoadingIndicator(),
                ),
                useOldImageOnUrlChange: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Tooltip(
                  message: 'Stream uptime',
                  preferBelow: false,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 10,
                      ),
                      const SizedBox(width: 4),
                      Uptime(
                        startTime: streamInfo.startedAt,
                        style: TextStyle(
                          color: surfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: 'Viewer count',
                  preferBelow: false,
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 14,
                        color: surfaceColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormat().format(streamInfo.viewerCount),
                        style: TextStyle(
                          color: surfaceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final streamerName =
        getReadableName(streamInfo.userName, streamInfo.userLogin);

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
      onLongPress: () {
        HapticFeedback.mediumImpact();

        showModalBottomSheet(
          context: context,
          builder: (context) => UserActionsModal(
            authStore: context.read<AuthStore>(),
            name: streamerName,
            userLogin: streamInfo.userLogin,
            userId: streamInfo.userId,
            showPinOption: showPinOption,
            isPinned: isPinned,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: showThumbnail ? 12 : 4,
          horizontal: 16,
        ),
        child: Column(
          children: [
            if (showThumbnail) thumbnail,
            VideoBar(
              streamInfo: streamInfo,
              showCategory: showCategory,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ],
        ),
      ),
    );
  }
}

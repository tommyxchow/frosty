import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/channel.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/photo_view.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/skeleton_loader.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:frosty/widgets/user_actions_modal.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a stream's thumbnail and details.
class StreamCard extends StatelessWidget {
  final StreamTwitch streamInfo;
  final bool showThumbnail;
  final bool showCategory;
  final bool showPinOption;
  final bool? isPinned;

  const StreamCard({
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
    final thumbnailWidth = min((size.width * pixelRatio) ~/ 3, 1920);
    final thumbnailHeight = min((thumbnailWidth * (9 / 16)).toInt(), 1080);

    final thumbnail = AspectRatio(
      aspectRatio: 16 / 9,
      child: FrostyCachedNetworkImage(
        imageUrl: streamInfo.thumbnailUrl.replaceFirst(
          '-{width}x{height}',
          '-${thumbnailWidth}x$thumbnailHeight',
        ),
        cacheKey: cacheKey,
        placeholder: (context, url) => const SkeletonLoader(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        useOldImageOnUrlChange: true,
      ),
    );

    final streamerName =
        getReadableName(streamInfo.userName, streamInfo.userLogin);

    final streamTitle = streamInfo.title.trim();
    final category =
        streamInfo.gameName.isNotEmpty ? streamInfo.gameName : 'No Category';

    const subFontSize = 14.0;

    final fontColor = DefaultTextStyle.of(context).style.color;

    final imageSection = ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          GestureDetector(
            onLongPress: () => showDialog(
              context: context,
              builder: (context) => FrostyPhotoViewDialog(
                imageUrl: streamInfo
                    .thumbnailUrl, // Pass original URL with {width}x{height} placeholder
                cacheKey: cacheKey,
              ),
            ),
            child: thumbnail,
          ),
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            clipBehavior: Clip.antiAlias,
            child: BlurredContainer(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              sigmaX: 8.0, // Less blur for subtlety
              sigmaY: 8.0, // Less blur for subtlety
              forceDarkMode: true,
              child: Uptime(
                startTime: streamInfo.startedAt,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      context.watch<FrostyThemes>().dark.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final streamInfoSection = Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfilePicture(
                userLogin: streamInfo.userLogin,
                radius: 10,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Tooltip(
                  message: streamerName,
                  preferBelow: false,
                  child: Text(
                    streamerName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fontColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Tooltip(
            message: streamTitle,
            preferBelow: false,
            child: Text(
              streamTitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: subFontSize,
                color: fontColor?.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (showCategory) ...[
            InkWell(
              onTap: streamInfo.gameName.isNotEmpty
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryStreams(
                            categoryId: streamInfo.gameId,
                          ),
                        ),
                      )
                  : null,
              child: Tooltip(
                message: category,
                preferBelow: false,
                child: Text(
                  category,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subFontSize,
                    color: fontColor?.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            '${NumberFormat().format(streamInfo.viewerCount)} viewers',
            style: TextStyle(
              fontSize: subFontSize,
              color: fontColor?.withValues(alpha: 0.8),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

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

        showModalBottomSheetWithProperFocus(
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
        padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: showThumbnail
              ? 16 + MediaQuery.of(context).padding.left
              : 4 + MediaQuery.of(context).padding.left,
          right: showThumbnail
              ? 16 + MediaQuery.of(context).padding.right
              : 4 + MediaQuery.of(context).padding.right,
        ),
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

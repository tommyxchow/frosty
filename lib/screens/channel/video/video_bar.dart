import 'package:flutter/material.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/profile_picture.dart';

class VideoBar extends StatelessWidget {
  final StreamTwitch streamInfo;
  final bool showCategory;
  final bool tappableCategory;
  final Color? titleTextColor;
  final Color? subtitleTextColor;
  final FontWeight? subtitleTextWeight;
  final EdgeInsets padding;

  const VideoBar({
    super.key,
    required this.streamInfo,
    this.showCategory = true,
    this.tappableCategory = true,
    this.titleTextColor,
    this.subtitleTextColor,
    this.subtitleTextWeight,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final streamTitle = streamInfo.title.trim();
    final category =
        streamInfo.gameName.isNotEmpty ? streamInfo.gameName : 'No Category';

    final streamerName =
        getReadableName(streamInfo.userName, streamInfo.userLogin);

    return Padding(
      padding: padding,
      child: Row(
        spacing: 12,
        children: [
          ProfilePicture(
            userLogin: streamInfo.userLogin,
            radius: 28,
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Tooltip(
                  message: streamerName,
                  showDuration: const Duration(seconds: 3),
                  child: Text(
                    streamerName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: titleTextColor,
                    ),
                  ),
                ),
                Tooltip(
                  message: streamTitle,
                  showDuration: const Duration(seconds: 5),
                  child: Text(
                    streamTitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleTextColor ??
                          Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                      fontWeight: subtitleTextWeight,
                    ),
                  ),
                ),
                if (showCategory) ...[
                  InkWell(
                    onTap: tappableCategory && streamInfo.gameName.isNotEmpty
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
                      showDuration: const Duration(seconds: 3),
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subtitleTextColor ??
                              Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                          fontWeight: subtitleTextWeight,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
        children: [
          ProfilePicture(
            userLogin: streamInfo.userLogin,
            radius: 28,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                  message: 'Streamer: $streamerName',
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
                const SizedBox(height: 2),
                Tooltip(
                  message: 'Title: ${streamInfo.title.trim()}',
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
                  const SizedBox(height: 2),
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
                      message:
                          'Category: ${streamInfo.gameName.isNotEmpty ? streamInfo.gameName : 'None'}',
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

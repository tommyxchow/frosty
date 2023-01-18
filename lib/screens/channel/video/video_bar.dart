import 'package:flutter/material.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:frosty/widgets/profile_picture.dart';

class VideoBar extends StatelessWidget {
  final StreamTwitch streamInfo;
  final bool showCategory;
  final bool tappableCategory;
  final Color? titleTextColor;
  final Color? subtitleTextColor;
  final FontWeight? subtitleTextWeight;

  const VideoBar({
    Key? key,
    required this.streamInfo,
    this.showCategory = true,
    this.tappableCategory = true,
    this.titleTextColor,
    this.subtitleTextColor,
    this.subtitleTextWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final streamTitle = streamInfo.title.trim();
    final category = streamInfo.gameName.isNotEmpty ? streamInfo.gameName : 'No Category';

    final streamerName = regexEnglish.hasMatch(streamInfo.userName)
        ? streamInfo.userName
        : '${streamInfo.userName} (${streamInfo.userLogin})';

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfilePicture(userLogin: streamInfo.userLogin),
          const SizedBox(width: 10.0),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: titleTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Tooltip(
                  message: 'Title: ${streamInfo.title.trim()}',
                  showDuration: const Duration(seconds: 5),
                  child: Text(
                    streamTitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleTextColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: subtitleTextWeight,
                    ),
                  ),
                ),
                if (showCategory) ...[
                  const SizedBox(height: 5.0),
                  InkWell(
                    onTap: tappableCategory && streamInfo.gameName.isNotEmpty
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
                      message: 'Category: ${streamInfo.gameName.isNotEmpty ? streamInfo.gameName : 'None'}',
                      showDuration: const Duration(seconds: 3),
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subtitleTextColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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

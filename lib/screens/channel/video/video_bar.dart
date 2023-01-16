import 'package:flutter/material.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:frosty/widgets/profile_picture.dart';

class VideoBar extends StatelessWidget {
  final StreamTwitch streamInfo;
  final bool showCategory;

  const VideoBar({
    Key? key,
    required this.streamInfo,
    this.showCategory = true,
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
                  message: streamerName,
                  child: Text(
                    streamerName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Tooltip(
                  message: streamTitle,
                  child: Text(
                    streamTitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                  ),
                ),
                if (showCategory) ...[
                  const SizedBox(height: 5.0),
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
                      message: category,
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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

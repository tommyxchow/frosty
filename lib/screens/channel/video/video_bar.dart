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
    final orientation = MediaQuery.of(context).orientation;

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
                  preferBelow: false,
                  child: Text(
                    streamerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5.0),
                Tooltip(
                  message: streamTitle,
                  preferBelow: false,
                  child: Text(
                    streamTitle,
                    maxLines: orientation == Orientation.portrait ? 1 : 3,
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
                      preferBelow: false,
                      child: Text(
                        category,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
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

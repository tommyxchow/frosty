import 'package:flutter/material.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/widgets/live_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:intl/intl.dart';

class StreamInfoBar extends StatelessWidget {
  final StreamTwitch streamInfo;
  final bool showCategory;
  final bool tappableCategory;
  final bool showUptime;
  final bool showViewerCount;
  final EdgeInsets padding;
  final TooltipTriggerMode tooltipTriggerMode;

  const StreamInfoBar({
    super.key,
    required this.streamInfo,
    this.showCategory = true,
    this.tappableCategory = true,
    this.showUptime = true,
    this.showViewerCount = true,
    this.padding = EdgeInsets.zero,
    this.tooltipTriggerMode = TooltipTriggerMode.tap,
  });

  @override
  Widget build(BuildContext context) {
    final streamTitle = streamInfo.title.trim();
    final streamerName =
        getReadableName(streamInfo.userName, streamInfo.userLogin);

    return Padding(
      padding: padding,
      child: Row(
        spacing: 12,
        children: [
          ProfilePicture(
            userLogin: streamInfo.userLogin,
            radius: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                // Top row: Streamer name + stream title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: 8,
                  children: [
                    Text(
                      streamerName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (streamTitle.isNotEmpty) ...[
                      Flexible(
                        child: Builder(
                          builder: (context) {
                            return Tooltip(
                              message: streamTitle,
                              triggerMode: tooltipTriggerMode,
                              child: Text(
                                streamTitle,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.bodySmallColor
                                      ?.withValues(alpha: 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                // Bottom row: Live indicator, uptime, viewer count, game name
                if (showUptime ||
                    showViewerCount ||
                    (showCategory && streamInfo.gameName.isNotEmpty)) ...[
                  Row(
                    children: [
                      if (showUptime || showViewerCount) ...[
                        const LiveIndicator(),
                        const SizedBox(width: 6),
                      ],
                      if (showUptime) ...[
                        Uptime(
                          startTime: streamInfo.startedAt,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (showViewerCount) const SizedBox(width: 8),
                      ],
                      if (showViewerCount) ...[
                        Icon(
                          Icons.visibility,
                          size: 14,
                          color: context.bodySmallColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          NumberFormat().format(streamInfo.viewerCount),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (showCategory &&
                          streamInfo.gameName.isNotEmpty &&
                          (showUptime || showViewerCount)) ...[
                        const SizedBox(width: 8),
                      ],
                      if (showCategory && streamInfo.gameName.isNotEmpty) ...[
                        Icon(
                          Icons.gamepad,
                          size: 14,
                          color: context.bodySmallColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Tooltip(
                            message: streamInfo.gameName,
                            triggerMode: tooltipTriggerMode,
                            child: tappableCategory
                                ? GestureDetector(
                                    onDoubleTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CategoryStreams(
                                          categoryId: streamInfo.gameId,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      streamInfo.gameName,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : Text(
                                    streamInfo.gameName,
                                    style:
                                        context.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ),
                      ],
                    ],
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

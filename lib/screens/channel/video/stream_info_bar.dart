import 'package:flutter/material.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/widgets/live_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:intl/intl.dart';

class StreamInfoBar extends StatelessWidget {
  final StreamTwitch? streamInfo;
  final Channel? offlineChannelInfo;
  final bool showCategory;
  final bool tappableCategory;
  final bool showUptime;
  final bool showViewerCount;
  final bool showOfflineIndicator;
  final EdgeInsets padding;
  final TooltipTriggerMode tooltipTriggerMode;
  final Color? textColor;
  final bool isCompact;
  final bool isInSharedChatMode;
  final bool isOffline;
  final bool showTextShadows;
  final String? displayName;

  const StreamInfoBar({
    super.key,
    this.streamInfo,
    this.offlineChannelInfo,
    this.showCategory = true,
    this.tappableCategory = true,
    this.showUptime = true,
    this.showViewerCount = true,
    this.showOfflineIndicator = true,
    this.padding = EdgeInsets.zero,
    this.tooltipTriggerMode = TooltipTriggerMode.tap,
    this.textColor,
    this.isCompact = false,
    this.isInSharedChatMode = false,
    this.isOffline = false,
    this.showTextShadows = true,
    this.displayName,
  });


  TextStyle _getBaseTextStyle(
    BuildContext context,
    double fontSize,
    FontWeight fontWeight,
  ) {
    return context.textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          shadows: showTextShadows ? kOverlayShadow : null,
        ) ??
        const TextStyle();
  }

  TextStyle _getSecondaryTextStyle(BuildContext context, double fontSize) {
    return context.textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color:
              textColor?.withValues(alpha: 0.7) ??
              context.bodySmallColor?.withValues(alpha: 0.7),
          shadows: showTextShadows ? kOverlayShadow : null,
        ) ??
        const TextStyle();
  }

  @override
  Widget build(BuildContext context) {
    final streamTitle = isOffline
        ? (offlineChannelInfo?.title.trim() ?? '')
        : (streamInfo?.title.trim() ?? '');
    final streamerName = isOffline
        ? getReadableName(
            offlineChannelInfo?.broadcasterName.isNotEmpty == true
                ? offlineChannelInfo?.broadcasterName ?? ''
                : displayName ?? '',
            offlineChannelInfo?.broadcasterLogin ?? '',
          )
        : getReadableName(
            streamInfo?.userName ?? '',
            streamInfo?.userLogin ?? '',
          );
    final secondLineSize = isCompact ? 13.0 : 14.0;

    return Padding(
      padding: padding,
      child: Row(
        spacing: 8,
        children: [
          Container(
            decoration: isInSharedChatMode
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  )
                : null,
            child: Padding(
              padding: isInSharedChatMode
                  ? const EdgeInsets.all(1.5)
                  : EdgeInsets.zero,
              child: ProfilePicture(
                userLogin: isOffline
                    ? (offlineChannelInfo?.broadcasterLogin.isNotEmpty == true
                          ? offlineChannelInfo?.broadcasterLogin ?? ''
                          : displayName ?? '')
                    : (streamInfo?.userLogin ?? ''),
                radius: 16,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Streamer name + stream title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: 4,
                  children: [
                    Tooltip(
                      message: streamerName,
                      triggerMode: tooltipTriggerMode,
                      child: Text(
                        streamerName,
                        style: _getBaseTextStyle(context, 14, FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (streamTitle.isNotEmpty) ...[
                      Flexible(
                        child: Tooltip(
                          message: streamTitle,
                          triggerMode: tooltipTriggerMode,
                          child: Text(
                            streamTitle,
                            style: _getSecondaryTextStyle(context, 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Bottom row: Live indicator, uptime, viewer count, game name or Offline text
                if (isOffline ||
                    (!isOffline && showUptime) ||
                    (!isOffline && showViewerCount) ||
                    (showCategory &&
                        (isOffline
                            ? (offlineChannelInfo?.gameName.isNotEmpty ?? false)
                            : (streamInfo?.gameName.isNotEmpty ?? false)))) ...[
                  Row(
                    children: [
                      if (isOffline && showOfflineIndicator) ...[
                        Text(
                          'Offline',
                          style: _getSecondaryTextStyle(
                            context,
                            secondLineSize,
                          ),
                        ),
                      ],
                      if (isOffline &&
                          showCategory &&
                          (offlineChannelInfo?.gameName.isNotEmpty ??
                              false)) ...[
                        if (showOfflineIndicator) const SizedBox(width: 8),
                        Icon(
                          Icons.gamepad,
                          size: secondLineSize,
                          color: (textColor ?? context.bodySmallColor)
                              ?.withValues(alpha: 0.7),
                          shadows: kOverlayShadow,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Tooltip(
                            message: offlineChannelInfo?.gameName ?? '',
                            triggerMode: tooltipTriggerMode,
                            child: tappableCategory
                                ? GestureDetector(
                                    onDoubleTap: () {
                                      if (offlineChannelInfo
                                              ?.gameId
                                              .isNotEmpty ??
                                          false) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryStreams(
                                                  categoryId:
                                                      offlineChannelInfo
                                                          ?.gameId ??
                                                      '',
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      offlineChannelInfo?.gameName ?? '',
                                      style: _getSecondaryTextStyle(
                                        context,
                                        secondLineSize,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : Text(
                                    offlineChannelInfo?.gameName ?? '',
                                    style: _getSecondaryTextStyle(
                                      context,
                                      secondLineSize,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ),
                      ] else ...[
                        if (!isOffline && (showUptime || showViewerCount)) ...[
                          const LiveIndicator(),
                          const SizedBox(width: 6),
                        ],
                        if (!isOffline && showUptime) ...[
                          Uptime(
                            startTime:
                                streamInfo?.startedAt ??
                                DateTime.now().toIso8601String(),
                            style: _getBaseTextStyle(
                              context,
                              secondLineSize,
                              FontWeight.w500,
                            ),
                          ),
                          if (!isOffline && showViewerCount)
                            const SizedBox(width: 8),
                        ],
                        if (!isOffline && showViewerCount) ...[
                          Icon(
                            Icons.visibility,
                            size: secondLineSize,
                            color: textColor ?? context.bodySmallColor,
                            shadows: kOverlayShadow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            NumberFormat().format(streamInfo?.viewerCount ?? 0),
                            style: _getBaseTextStyle(
                              context,
                              secondLineSize,
                              FontWeight.w500,
                            ),
                          ),
                        ],
                        if (!isOffline &&
                            showCategory &&
                            (streamInfo?.gameName.isNotEmpty ?? false) &&
                            (showUptime || showViewerCount)) ...[
                          const SizedBox(width: 8),
                        ],
                        if (!isOffline &&
                            showCategory &&
                            (streamInfo?.gameName.isNotEmpty ?? false)) ...[
                          Icon(
                            Icons.gamepad,
                            size: secondLineSize,
                            color: textColor ?? context.bodySmallColor,
                            shadows: kOverlayShadow,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Tooltip(
                              message: streamInfo?.gameName ?? '',
                              triggerMode: tooltipTriggerMode,
                              child: tappableCategory
                                  ? GestureDetector(
                                      onDoubleTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CategoryStreams(
                                            categoryId:
                                                streamInfo?.gameId ?? '',
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        streamInfo?.gameName ?? '',
                                        style: _getBaseTextStyle(
                                          context,
                                          secondLineSize,
                                          FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  : Text(
                                      streamInfo?.gameName ?? '',
                                      style: _getBaseTextStyle(
                                        context,
                                        secondLineSize,
                                        FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ),
                        ],
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

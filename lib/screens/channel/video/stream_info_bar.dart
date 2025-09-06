import 'package:flutter/material.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
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
    this.displayName,
  });

  static const _iconShadow = [
    Shadow(
      offset: Offset(0, 1),
      blurRadius: 4,
      color: Color.fromRGBO(0, 0, 0, 0.3),
    ),
  ];

  static const _textShadow = [
    Shadow(
      offset: Offset(0, 1),
      blurRadius: 4,
      color: Color.fromRGBO(0, 0, 0, 0.3),
    ),
  ];

  TextStyle _getBaseTextStyle(
    BuildContext context,
    double fontSize,
    FontWeight fontWeight,
  ) {
    return context.textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          shadows: _textShadow,
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
          shadows: _textShadow,
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
        spacing: 12,
        children: [
          Container(
            decoration: isInSharedChatMode
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: textColor ?? Theme.of(context).colorScheme.primary,
                      width: 1.5,
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
                  spacing: 8,
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
                    showUptime ||
                    showViewerCount ||
                    (showCategory &&
                        (streamInfo?.gameName.isNotEmpty ?? false))) ...[
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
                          shadows: _iconShadow,
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
                        if (showUptime || showViewerCount) ...[
                          const LiveIndicator(),
                          const SizedBox(width: 6),
                        ],
                        if (showUptime) ...[
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
                          if (showViewerCount) const SizedBox(width: 8),
                        ],
                        if (showViewerCount) ...[
                          Icon(
                            Icons.visibility,
                            size: secondLineSize,
                            color: textColor ?? context.bodySmallColor,
                            shadows: _iconShadow,
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
                        if (showCategory &&
                            (streamInfo?.gameName.isNotEmpty ?? false) &&
                            (showUptime || showViewerCount)) ...[
                          const SizedBox(width: 8),
                        ],
                        if (showCategory &&
                            (streamInfo?.gameName.isNotEmpty ?? false)) ...[
                          Icon(
                            Icons.gamepad,
                            size: secondLineSize,
                            color: textColor ?? context.bodySmallColor,
                            shadows: _iconShadow,
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

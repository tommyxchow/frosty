import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/top/category_streams.dart';
import 'package:frosty/widgets/animate_scale.dart';
import 'package:frosty/widgets/block_report_modal.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a stream's thumbnail and details.
class StreamCard extends StatefulWidget {
  final ListStore listStore;
  final StreamTwitch streamInfo;
  final bool showUptime;
  final bool showThumbnail;
  final bool large;
  final bool showCategory;

  const StreamCard({
    Key? key,
    required this.listStore,
    required this.streamInfo,
    required this.showUptime,
    required this.showThumbnail,
    required this.large,
    this.showCategory = true,
  }) : super(key: key);

  @override
  State<StreamCard> createState() => _StreamCardState();
}

class _StreamCardState extends State<StreamCard> {
  @override
  Widget build(BuildContext context) {
    final time = DateTime.now();
    final cacheUrlExtension = time.day.toString() + time.hour.toString() + (time.minute ~/ 5).toString();

    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Calculate the width and height of the thumbnail based on the device width and the stream card size setting.
    // Constraint the resolution to 1920x1080 since that's the max resolution of the Twitch API.
    final thumbnailWidth = min((size.width * pixelRatio) ~/ (widget.large ? 1 : 3), 1920);
    final thumbnailHeight = min((thumbnailWidth * (9 / 16)).toInt(), 1080);

    final image = AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: widget.streamInfo.thumbnailUrl.replaceFirst('-{width}x{height}', '-${thumbnailWidth}x$thumbnailHeight') + cacheUrlExtension,
        placeholder: (context, url) => const LoadingIndicator(),
        useOldImageOnUrlChange: true,
      ),
    );

    final thumbnail = widget.large
        ? Container(
            foregroundDecoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                ],
              ),
            ),
            child: image,
          )
        : image;

    final streamerName = regexEnglish.hasMatch(widget.streamInfo.userName)
        ? widget.streamInfo.userName
        : '${widget.streamInfo.userName} (${widget.streamInfo.userLogin})';

    final subFontSize = widget.large ? 16.0 : 14.0;

    final fontColor = widget.large ? Colors.white : DefaultTextStyle.of(context).style.color;

    final imageSection = ClipRRect(
      borderRadius: widget.large ? const BorderRadius.all(Radius.circular(10.0)) : const BorderRadius.all(Radius.circular(5.0)),
      child: widget.showUptime
          ? Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                thumbnail,
                if (widget.large)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      DateTime.now().difference(DateTime.parse(widget.streamInfo.startedAt)).toString().split('.')[0],
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )
                else
                  Container(
                    color: const Color.fromRGBO(0, 0, 0, 0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      DateTime.now().difference(DateTime.parse(widget.streamInfo.startedAt)).toString().split('.')[0],
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  )
              ],
            )
          : thumbnail,
    );

    final streamInfoSection = Padding(
      padding: widget.large ? const EdgeInsets.all(10.0) : const EdgeInsets.only(left: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfilePicture(
                userLogin: widget.streamInfo.userLogin,
                radius: 10.0,
              ),
              const SizedBox(width: 5.0),
              Flexible(
                child: Tooltip(
                  message: streamerName,
                  preferBelow: false,
                  child: Text(
                    streamerName,
                    style: TextStyle(
                      fontSize: widget.large ? 20.0 : 16.0,
                      fontWeight: FontWeight.bold,
                      color: fontColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5.0),
          Tooltip(
            message: widget.streamInfo.title.trim(),
            preferBelow: false,
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.streamInfo.title.trim(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: subFontSize,
                color: fontColor,
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          if (widget.showCategory) ...[
            InkWell(
              child: Tooltip(
                message: widget.streamInfo.gameName,
                preferBelow: false,
                child: Text(
                  widget.streamInfo.gameName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subFontSize,
                    color: fontColor?.withOpacity(0.8),
                  ),
                ),
              ),
              onTap: () async {
                final category = await context.read<TwitchApi>().getCategory(
                      headers: context.read<AuthStore>().headersTwitch,
                      gameId: widget.streamInfo.gameId,
                    );

                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryStreams(
                      listStore: ListStore(
                        twitchApi: context.read<TwitchApi>(),
                        authStore: context.read<AuthStore>(),
                        listType: ListType.category,
                        categoryInfo: category.data.first,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 5.0),
          ],
          Text(
            '${NumberFormat().format(widget.streamInfo.viewerCount)} viewers',
            style: TextStyle(
              fontSize: subFontSize,
              color: fontColor?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );

    return AnimateScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoChat(
            userId: widget.streamInfo.userId,
            userName: widget.streamInfo.userName,
            userLogin: widget.streamInfo.userLogin,
          ),
        ),
      ),
      onLongPress: () {
        HapticFeedback.mediumImpact();

        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => BlockReportModal(
            authStore: widget.listStore.authStore,
            name: streamerName,
            userLogin: widget.streamInfo.userLogin,
            userId: widget.streamInfo.userId,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: widget.showThumbnail ? 15.0 : 5.0),
        child: widget.large
            ? Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [imageSection, streamInfoSection],
              )
            : Row(
                children: [
                  if (widget.showThumbnail)
                    Flexible(
                      flex: 1,
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

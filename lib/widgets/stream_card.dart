import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/video_chat.dart';
import 'package:intl/intl.dart';

/// A tappable card widget that displays a stream's thumbnail and details.
class StreamCard extends StatelessWidget {
  final Stream streamInfo;

  const StreamCard({Key? key, required this.streamInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return VideoChat(
                title: streamInfo.title,
                userName: streamInfo.userName,
                userLogin: streamInfo.userLogin,
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CachedNetworkImage(
                    imageUrl: streamInfo.thumbnailUrl.replaceFirst('-{width}x{height}', '-440x248') + (DateTime.now().minute ~/ 5).toString(),
                    useOldImageOnUrlChange: true,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      DateTime.now().difference(DateTime.parse(streamInfo.startedAt)).toString().split('.')[0],
                      style: const TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      streamInfo.userName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(streamInfo.title.replaceAll('\n', '')),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      streamInfo.gameName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${NumberFormat().format(streamInfo.viewerCount)} viewers',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

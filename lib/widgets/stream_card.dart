import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/video_chat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// A tappable card widget that displays a stream's thumbnail and details.
class StreamCard extends StatelessWidget {
  final Stream streamInfo;

  const StreamCard({Key? key, required this.streamInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return VideoChat(
                  userLogin: streamInfo.userLogin,
                  userName: streamInfo.userName,
                );
              },
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: CachedNetworkImage(
                  imageUrl: streamInfo.thumbnailUrl.replaceFirst('-{width}x{height}', '-440x248') + (DateTime.now().minute ~/ 5).toString(),
                  useOldImageOnUrlChange: true,
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      streamInfo.userName,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/providers/chat_provider.dart';
import 'package:frosty/screens/video_chat.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// A card widget that displays a live channel's thumbnail and details.
class ChannelCard extends StatelessWidget {
  final Channel channelInfo;

  const ChannelCard({Key? key, required this.channelInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) {
                return Scaffold(
                  body: ChangeNotifierProvider<ChatProvider>(
                    create: (context) => ChatProvider(channelInfo: channelInfo),
                    child: VideoChat(channelInfo: channelInfo),
                  ),
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
                  imageUrl: channelInfo.thumbnailUrl.replaceFirst('-{width}x{height}', '-440x248'),
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
                      channelInfo.userName,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(channelInfo.title),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      channelInfo.gameName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${NumberFormat().format(channelInfo.viewerCount)} viewers',
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

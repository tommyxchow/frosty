import 'package:flutter/widgets.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/widgets/chat.dart';
import 'package:frosty/widgets/video.dart';

class VideoChat extends StatelessWidget {
  final Channel channelInfo;

  const VideoChat({Key? key, required this.channelInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Video(channelName: channelInfo.userLogin),
          ),
          Expanded(
            child: Chat(channelInfo: channelInfo),
          )
        ],
      ),
    );
  }
}

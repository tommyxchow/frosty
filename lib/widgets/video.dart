import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Video extends StatelessWidget {
  final String channelName;

  const Video({Key? key, required this.channelName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://player.twitch.tv/?channel=$channelName&muted=false&parent=localhost.com',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}

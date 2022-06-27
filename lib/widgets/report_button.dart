import 'package:flutter/material.dart';
import 'package:frosty/widgets/button.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReportButton extends StatelessWidget {
  final String userLogin;
  final String displayName;

  const ReportButton({
    Key? key,
    required this.userLogin,
    required this.displayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Button(
      icon: const Icon(Icons.report),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Report'),
              ),
              body: WebView(
                initialUrl: 'https://www.twitch.tv/$userLogin/report',
                javascriptMode: JavascriptMode.unrestricted,
              ),
            );
          },
        ),
      ),
      color: Colors.red,
      fill: true,
      child: Text('Report $displayName'),
    );
  }
}

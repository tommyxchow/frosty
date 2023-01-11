import 'package:flutter/material.dart';
import 'package:frosty/widgets/app_bar.dart';
import 'package:frosty/widgets/button.dart';
import 'package:heroicons/heroicons.dart';
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
      icon: const HeroIcon(HeroIcons.flag, style: HeroIconStyle.mini),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: const FrostyAppBar(
                title: Text('Report'),
              ),
              body: WebView(
                initialUrl: 'https://www.twitch.tv/$userLogin/report',
                javascriptMode: JavascriptMode.unrestricted,
              ),
            );
          },
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      color: Colors.red.shade700,
      fill: true,
      child: Text('Report $displayName'),
    );
  }
}

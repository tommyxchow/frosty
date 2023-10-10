import 'package:flutter/material.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/app_bar.dart';
import 'package:frosty/widgets/list_tile.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BlockReportModal extends StatelessWidget {
  final AuthStore authStore;
  final String name;
  final String userLogin;
  final String userId;

  const BlockReportModal({
    Key? key,
    required this.authStore,
    required this.name,
    required this.userLogin,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (authStore.isLoggedIn)
          FrostyListTile(
            leading: const Icon(Icons.block_rounded),
            onTap: () => authStore
                .showBlockDialog(context,
                    targetUser: name, targetUserId: userId)
                .then((_) => Navigator.pop(context)),
            title: 'Block $name',
          ),
        FrostyListTile(
          leading: const Icon(Icons.outlined_flag_rounded),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: FrostyAppBar(
                    title: Text('Report $name'),
                  ),
                  body: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(
                        Uri.parse('https://www.twitch.tv/$userLogin/report'),
                      ),
                  ),
                );
              },
            ),
          ),
          title: 'Report $name',
        )
      ],
    );
  }
}

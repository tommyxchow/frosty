import 'package:flutter/material.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/app_bar.dart';
import 'package:frosty/widgets/bottom_sheet.dart';
import 'package:frosty/widgets/list_tile.dart';
import 'package:heroicons/heroicons.dart';
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
    return FrostyBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (authStore.isLoggedIn)
            FrostyListTile(
              leading: const HeroIcon(HeroIcons.noSymbol),
              onTap: () => authStore
                  .showBlockDialog(context, targetUser: name, targetUserId: userId)
                  .then((_) => Navigator.pop(context)),
              title: 'Block $name',
            ),
          FrostyListTile(
            leading: const HeroIcon(HeroIcons.flag),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Scaffold(
                    appBar: FrostyAppBar(
                      title: Text('Report $name'),
                    ),
                    body: WebView(
                      initialUrl: 'https://www.twitch.tv/$userLogin/report',
                      javascriptMode: JavascriptMode.unrestricted,
                    ),
                  );
                },
              ),
            ),
            title: 'Report $name',
          )
        ],
      ),
    );
  }
}

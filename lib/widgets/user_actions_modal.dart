import 'package:flutter/material.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserActionsModal extends StatelessWidget {
  final AuthStore authStore;
  final String name;
  final String userLogin;
  final String userId;
  final bool showPinOption;
  final bool? isPinned;

  const UserActionsModal({
    super.key,
    required this.authStore,
    required this.name,
    required this.userLogin,
    required this.userId,
    this.showPinOption = false,
    this.isPinned,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      shrinkWrap: true,
      children: [
        if (showPinOption)
          ListTile(
            leading: const Icon(Icons.push_pin_outlined),
            title: Text('${isPinned == true ? 'Unpin' : 'Pin'} $name'),
            onTap: () {
              if (isPinned == true) {
                context.read<SettingsStore>().pinnedChannelIds = [
                  ...context.read<SettingsStore>().pinnedChannelIds
                    ..remove(userId),
                ];
              } else {
                context.read<SettingsStore>().pinnedChannelIds = [
                  ...context.read<SettingsStore>().pinnedChannelIds,
                  userId,
                ];
              }

              Navigator.pop(context);
            },
          ),
        if (authStore.isLoggedIn)
          ListTile(
            leading: const Icon(Icons.block_rounded),
            onTap: () => authStore
                .showBlockDialog(
              context,
              targetUser: name,
              targetUserId: userId,
            )
                .then((_) {
              if (context.mounted) {
                Navigator.pop(context);
              }
            }),
            title: Text('Block $name'),
          ),
        ListTile(
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
          title: Text('Report $name'),
        ),
      ],
    );
  }
}

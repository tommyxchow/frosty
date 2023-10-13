import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/account/account_options.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/widgets/settings_tile_route.dart';
import 'package:frosty/widgets/app_bar.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileCard extends StatelessWidget {
  final AuthStore authStore;

  const ProfileCard({Key? key, required this.authStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (authStore.error != null) {
          return ListTile(
            leading: const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
            ),
            title: const Text('Failed to connect'),
            trailing: FilledButton.tonal(
              onPressed: authStore.init,
              child: const Text('Reconnect'),
            ),
          );
        }
        if (authStore.isLoggedIn && authStore.user.details != null) {
          return SettingsTileRoute(
            leading: ProfilePicture(
              userLogin: authStore.user.details!.login,
              radius: 12,
            ),
            title: authStore.user.details!.displayName,
            child: AccountOptions(authStore: authStore),
          );
        }
        return ListTile(
          leading: const Icon(Icons.no_accounts_rounded),
          title: const Text('Anonymous'),
          subtitle: const Text(
            'Log in to enable the ability to chat, view followed streams, and more.',
          ),
          trailing: const SizedBox(
            height: double.infinity,
            child: Icon(Icons.chevron_right_rounded),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Scaffold(
                  appBar: const FrostyAppBar(
                    title: Text('Connect with Twitch'),
                  ),
                  body: WebViewWidget(
                    controller: authStore.createAuthWebViewController(),
                  ),
                );
              },
            ),
          ),
          onLongPress: () async {
            final clipboardText =
                (await Clipboard.getData(Clipboard.kTextPlain))?.text;

            if (clipboardText == null) return;

            authStore.login(token: clipboardText);
          },
        );
      },
    );
  }
}

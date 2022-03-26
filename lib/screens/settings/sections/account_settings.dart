import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/blocked_users.dart';
import 'package:frosty/screens/settings/widgets/profile_card.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AccountSettings extends StatelessWidget {
  final SettingsStore settingsStore;
  final AuthStore authStore;

  const AccountSettings({
    Key? key,
    required this.settingsStore,
    required this.authStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('ACCOUNT'),
          ProfileCard(authStore: authStore),
          if (authStore.isLoggedIn) ...[
            ListTile(
              title: const Text('Blocked Users'),
              trailing: Icon(Icons.adaptive.arrow_forward),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlockedUsers(
                    authStore: authStore,
                  ),
                ),
              ),
            ),
            ListTile(
              isThreeLine: true,
              title: const Text('Log in to WebView'),
              subtitle: const Text('Lets you avoid ads on your subscribed streamers or if you have Turbo.'),
              trailing: Icon(Icons.adaptive.arrow_forward),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Log In to WebView'),
                      ),
                      body: const WebView(
                        initialUrl: 'https://www.twitch.tv/login',
                        javascriptMode: JavascriptMode.unrestricted,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

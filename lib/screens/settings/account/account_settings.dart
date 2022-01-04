import 'package:flutter/material.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/settings/account/blocked_users.dart';
import 'package:frosty/screens/settings/account/profile_card.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          'Account',
          padding: EdgeInsets.all(10.0),
        ),
        ProfileCard(authStore: authStore),
        if (authStore.isLoggedIn)
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
          )
        // Add prompt explaining what this does before proceeding.
        // Center(
        //   child: ElevatedButton(
        //     child: const Text('Log In to WebView'),
        //     onPressed: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) {
        //           return Scaffold(
        //             appBar: AppBar(
        //               title: const Text('Log In to WebView'),
        //             ),
        //             body: const WebView(
        //               initialUrl: 'https://www.twitch.tv/login',
        //               javascriptMode: JavascriptMode.unrestricted,
        //             ),
        //           );
        //         },
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

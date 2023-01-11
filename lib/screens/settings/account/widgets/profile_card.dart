import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/account/account_options.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/app_bar.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:heroicons/heroicons.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileCard extends StatelessWidget {
  final AuthStore authStore;

  const ProfileCard({Key? key, required this.authStore}) : super(key: key);

  Future<void> _showLoginDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Log In',
        content: Column(
          children: [
            Button(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Scaffold(
                      appBar: const FrostyAppBar(
                        title: Text('Connect with Twitch'),
                      ),
                      body: WebView(
                        initialUrl: authStore.loginUri.toString(),
                        navigationDelegate: authStore.handleNavigation,
                        javascriptMode: JavascriptMode.unrestricted,
                      ),
                    );
                  },
                ),
              ),
              icon: const Icon(SimpleIcons.twitch),
              child: const Text(
                'Connect with Twitch',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const Center(
              child: Text(
                'Or',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              autocorrect: false,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Token',
              ),
              onSubmitted: (token) {
                authStore.login(token: token);
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (authStore.error != null) {
          return ListTile(
            leading: const HeroIcon(
              HeroIcons.exclamationCircle,
              color: Colors.red,
            ),
            title: const Text(
              'Failed to connect',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            trailing: Button(
              onPressed: authStore.init,
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: const Text('Reconnect'),
            ),
          );
        }
        if (authStore.isLoggedIn && authStore.user.details != null) {
          return ListTile(
            leading: ProfilePicture(
              userLogin: authStore.user.details!.login,
              radius: 12,
            ),
            title: Text(
              authStore.user.details!.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const HeroIcon(HeroIcons.chevronRight, style: HeroIconStyle.mini),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: const FrostyAppBar(title: Text('Account')),
                  body: AccountOptions(authStore: authStore),
                ),
              ),
            ),
          );
        }
        return ListTile(
          isThreeLine: true,
          leading: const HeroIcon(HeroIcons.questionMarkCircle),
          title: const Text('Anonymous', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Tap to log in and enable the ability to chat, view followed streams, and more.'),
          trailing: const SizedBox(
            height: double.infinity,
            child: HeroIcon(
              HeroIcons.chevronRight,
              style: HeroIconStyle.mini,
            ),
          ),
          onTap: () => _showLoginDialog(context),
        );
      },
    );
  }
}

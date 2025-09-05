import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/onboarding/login_webview.dart';
import 'package:frosty/screens/settings/account/account_options.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/profile_picture.dart';

class ProfileCard extends StatelessWidget {
  final AuthStore authStore;

  const ProfileCard({super.key, required this.authStore});

  Future<void> _showAccountOptionsModalBottomSheet(BuildContext context) {
    return showModalBottomSheetWithProperFocus(
      context: context,
      builder: (context) {
        return AccountOptions(authStore: authStore);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (authStore.error != null) {
          return ListTile(
            leading: Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Unable to connect to Twitch'),
            trailing: FilledButton.tonal(
              onPressed: authStore.init,
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
            title: Text(authStore.user.details!.displayName),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showAccountOptionsModalBottomSheet(context),
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
              builder: (context) => LoginWebView(),
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

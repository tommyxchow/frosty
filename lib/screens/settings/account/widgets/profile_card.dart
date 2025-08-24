import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/account/account_options.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileCard extends StatelessWidget {
  final AuthStore authStore;

  const ProfileCard({super.key, required this.authStore});

  Future<void> _showAccountOptionsModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
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
              builder: (context) {
                final theme = Theme.of(context);

                return Scaffold(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  extendBody: true,
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    centerTitle: false,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness:
                          theme.brightness == Brightness.dark
                              ? Brightness.light
                              : Brightness.dark,
                    ),
                    leading: IconButton(
                      tooltip: 'Back',
                      icon: Icon(Icons.adaptive.arrow_back_rounded),
                      onPressed: Navigator.of(context).pop,
                    ),
                    title: const Text('Connect with Twitch'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.help_rounded),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Workaround for the Twitch cookie banner',
                              ),
                              content: const Text(
                                'If the Twitch cookie banner is still blocking the login, try clicking one of the links in the cookie policy description and navigating until you reach the Twitch home page. From there, you can try logging in on the top right profile icon. Once logged in, exit this page and then try again.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: Navigator.of(context).pop,
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  body: Stack(
                    children: [
                      // WebView content
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top +
                                kToolbarHeight,
                          ),
                          child: WebViewWidget(
                            controller: authStore.createAuthWebViewController(),
                          ),
                        ),
                      ),
                      // Blurred app bar overlay
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: BlurredContainer(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top,
                            left: MediaQuery.of(context).padding.left,
                            right: MediaQuery.of(context).padding.right,
                          ),
                          child: const SizedBox(height: kToolbarHeight),
                        ),
                      ),
                    ],
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

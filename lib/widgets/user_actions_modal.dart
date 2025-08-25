import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/blurred_container.dart';
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
                    title: Text('Report $name'),
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
                            controller: WebViewController()
                              ..setJavaScriptMode(JavaScriptMode.unrestricted)
                              ..loadRequest(
                                Uri.parse(
                                  'https://www.twitch.tv/$userLogin/report',
                                ),
                              )
                              ..setNavigationDelegate(
                                NavigationDelegate(
                                  onWebResourceError: (error) {
                                    debugPrint(
                                      'WebView error: ${error.description}',
                                    );
                                  },
                                ),
                              ),
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
          title: Text('Report $name'),
        ),
      ],
    );
  }
}

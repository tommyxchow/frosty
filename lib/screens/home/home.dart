import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/home/search/search.dart';
import 'package:frosty/screens/home/stores/home_store.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/top/top_section.dart';
import 'package:frosty/screens/home/widgets/streams_list.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final _authStore = context.read<AuthStore>();

  late final _homeStore = HomeStore(authStore: _authStore);

  Future<void> _showStartDialog() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('first_run') == false) return;

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Frosty v${packageInfo.version} (${packageInfo.buildNumber})',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Thank you so much for downloading and trying out Frosty! Hopefully it will make your mobile Twitch viewing experience a little more enjoyable.'),
            const SizedBox(height: 20.0),
            const Text(
                'You can see the full changelog on the app store listing or the "Releases" section on the GitHub repo (link on the top right of settings).'),
            const SizedBox(height: 20.0),
            const Text('You can also find the FAQ on the GitHub repo (link in Settings -> Other).'),
            const SizedBox(height: 20.0),
            const Text('If you have any issues or feature requests for the app, please open an issue on GitHub.'),
            if (Platform.isAndroid) ...[
              const SizedBox(height: 20.0),
              const Text('NOTE: Due to limitations with the Twitch web player, video streams may not work on Android versions below 7.1.1.'),
            ]
          ],
        ),
        actions: [
          Button(
            onPressed: () {
              prefs.setBool('first_run', false);

              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _showStartDialog();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Observer(
            builder: (_) {
              final titles = [
                if (_authStore.isLoggedIn) 'Followed Streams',
                'Top',
                'Search',
              ];

              return Text(titles[_homeStore.selectedIndex]);
            },
          ),
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Settings(settingsStore: context.read<SettingsStore>()),
                ),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: Observer(
            builder: (_) => IndexedStack(
              index: _homeStore.selectedIndex,
              children: [
                if (_authStore.isLoggedIn)
                  StreamsList(
                    listType: ListType.followed,
                    scrollController: _homeStore.followedScrollController,
                  ),
                TopSection(
                  homeStore: _homeStore,
                ),
                const Search(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Observer(
          builder: (_) => BottomNavigationBar(
            items: [
              if (_authStore.isLoggedIn)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Followed',
                ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.arrow_upward),
                label: 'Top',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
            currentIndex: _homeStore.selectedIndex,
            onTap: _homeStore.handleTap,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeStore.dispose();
    super.dispose();
  }
}

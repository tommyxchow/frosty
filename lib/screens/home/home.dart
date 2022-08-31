import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/home/home_store.dart';
import 'package:frosty/screens/home/search/search.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/home/stream_list/streams_list.dart';
import 'package:frosty/screens/home/top/top.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/screens/settings/settings_store.dart';
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
          children: const [
            Text(
                'Thank you so much for downloading and trying out Frosty! Hopefully it\'ll make your mobile Twitch viewing experience a little more enjoyable.'),
            SizedBox(height: 20.0),
            Text(
                'Frosty is completely free and open-source. If you\'d like to explore the source code, report an issue, or make a feature request, check out the GitHub repo (link at the top-right of settings).'),
            SizedBox(height: 20.0),
            Text('You can also find links to the full changelog and FAQ in Settings -> Other.'),
            SizedBox(height: 20.0),
            Text('Don\'t forget to leave a rating and/or review on the app store!'),
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
          child: Column(
            children: [
              Expanded(
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
                      Search(
                        scrollController: _homeStore.searchScrollController,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1.0, thickness: 1.0),
            ],
          ),
        ),
        bottomNavigationBar: Observer(
          builder: (_) => BottomNavigationBar(
            unselectedFontSize: 12.0,
            selectedFontSize: 12.0,
            type: BottomNavigationBarType.fixed,
            items: [
              if (_authStore.isLoggedIn)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Followed',
                  tooltip: 'Followed streams',
                ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.arrow_upward),
                label: 'Top',
                tooltip: 'Top streams and categories',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
                tooltip: 'Search for channels and categories',
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

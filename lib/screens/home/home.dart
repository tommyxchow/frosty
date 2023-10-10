import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/home_store.dart';
import 'package:frosty/screens/home/search/search.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/home/stream_list/streams_list.dart';
import 'package:frosty/screens/home/top/top.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final _authStore = context.read<AuthStore>();

  late final _homeStore = HomeStore(authStore: _authStore);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([]);

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Observer(
            builder: (_) {
              final titles = [
                if (_authStore.isLoggedIn) 'Following',
                'Top',
                'Search',
              ];

              return Text(titles[_homeStore.selectedIndex]);
            },
          ),
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Settings(settingsStore: context.read<SettingsStore>()),
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
                Search(
                  scrollController: _homeStore.searchScrollController,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Observer(
          builder: (_) => NavigationBar(
            destinations: [
              if (_authStore.isLoggedIn)
                NavigationDestination(
                  icon: _homeStore.selectedIndex == 0
                      ? const Icon(Icons.favorite_rounded)
                      : const Icon(Icons.favorite_border_rounded),
                  label: 'Following',
                  tooltip: 'Followed streams',
                ),
              const NavigationDestination(
                icon: Icon(Icons.arrow_upward_rounded),
                label: 'Top',
                tooltip: 'Top streams and categories',
              ),
              const NavigationDestination(
                icon: Icon(Icons.search_rounded),
                label: 'Search',
                tooltip: 'Search for channels and categories',
              ),
            ],
            selectedIndex: _homeStore.selectedIndex,
            onDestinationSelected: _homeStore.handleTap,
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

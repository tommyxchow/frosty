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

              return Text(
                titles[_homeStore.selectedIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              );
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
                if (_authStore.isLoggedIn) const StreamsList(listType: ListType.followed),
                const TopSection(),
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

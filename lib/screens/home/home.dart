import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/home/search/search.dart';
import 'package:frosty/screens/home/stores/categories_store.dart';
import 'package:frosty/screens/home/stores/home_store.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/stores/search_store.dart';
import 'package:frosty/screens/home/top/top_section.dart';
import 'package:frosty/screens/home/widgets/streams_list.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final HomeStore homeStore;
  final ListStore? followedStreamsStore;
  final ListStore topSectionStore;
  final CategoriesStore categoriesSectionStore;
  final SearchStore searchStore;

  const Home({
    Key? key,
    required this.homeStore,
    required this.followedStreamsStore,
    required this.topSectionStore,
    required this.categoriesSectionStore,
    required this.searchStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authStore = context.read<AuthStore>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Observer(
          builder: (_) {
            final titles = [
              if (authStore.isLoggedIn) 'Followed Streams',
              'Top',
              'Search',
            ];

            return Text(titles[homeStore.selectedIndex]);
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
            index: homeStore.selectedIndex,
            children: [
              if (authStore.isLoggedIn) StreamsList(store: followedStreamsStore!),
              TopSection(
                topSectionStore: topSectionStore,
                categoriesSectionStore: categoriesSectionStore,
              ),
              Search(searchStore: searchStore),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Observer(
        builder: (_) => BottomNavigationBar(
          items: [
            if (authStore.isLoggedIn)
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
          currentIndex: homeStore.selectedIndex,
          onTap: homeStore.handleTap,
        ),
      ),
    );
  }
}

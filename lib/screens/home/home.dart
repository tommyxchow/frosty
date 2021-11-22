import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/categories/categories.dart';
import 'package:frosty/screens/categories/categories_store.dart';
import 'package:frosty/screens/home/home_store.dart';
import 'package:frosty/screens/search/search.dart';
import 'package:frosty/screens/search/search_store.dart';
import 'package:frosty/screens/stream_list/streams_followed/followed_streams.dart';
import 'package:frosty/screens/stream_list/streams_followed/followed_streams_store.dart';
import 'package:frosty/screens/stream_list/streams_top/top_streams.dart';
import 'package:frosty/screens/stream_list/streams_top/top_streams_store.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final HomeStore homeStore;
  final TopStreamsStore topStreamsStore;
  final FollowedStreamsStore followedStreamsStore;
  final CategoriesStore categoriesStore;
  final SearchStore searchStore;

  const Home({
    Key? key,
    required this.homeStore,
    required this.topStreamsStore,
    required this.followedStreamsStore,
    required this.categoriesStore,
    required this.searchStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('build home');
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Observer(
          builder: (_) {
            final titles = [
              if (context.read<AuthStore>().isLoggedIn) 'Followed Streams',
              'Top Streams',
              'Categories',
              'Search',
            ];
            return Text(
              titles[homeStore.selectedIndex],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Settings(settingsStore: context.read<SettingsStore>());
                  },
                ),
              );
            },
          )
        ],
      ),
      body: Observer(
        builder: (_) {
          return IndexedStack(
            index: homeStore.selectedIndex,
            children: [
              if (context.read<AuthStore>().isLoggedIn) FollowedStreams(store: followedStreamsStore),
              TopStreams(store: topStreamsStore),
              Categories(store: categoriesStore),
              Search(store: searchStore),
            ],
          );
        },
      ),
      bottomNavigationBar: Observer(
        builder: (_) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              if (context.read<AuthStore>().isLoggedIn)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Followed',
                ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.arrow_upward),
                label: 'Top',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.games),
                label: 'Categories',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
            currentIndex: homeStore.selectedIndex,
            onTap: homeStore.handleTap,
          );
        },
      ),
    );
  }
}

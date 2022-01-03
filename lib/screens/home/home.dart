import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/followed_streams/followed_streams.dart';
import 'package:frosty/screens/followed_streams/followed_streams_store.dart';
import 'package:frosty/screens/search/search.dart';
import 'package:frosty/screens/search/search_store.dart';
import 'package:frosty/screens/top/categories/categories_store.dart';
import 'package:frosty/screens/top/streams/top_streams_store.dart';
import 'package:frosty/screens/top/top_section.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final TopStreamsStore topStreamsStore;
  final FollowedStreamsStore followedStreamsStore;
  final CategoriesStore categoriesStore;
  final SearchStore searchStore;

  const Home({
    Key? key,
    required this.topStreamsStore,
    required this.followedStreamsStore,
    required this.categoriesStore,
    required this.searchStore,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _handleTap(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

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
            return Text(
              titles[_selectedIndex],
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
      body: SafeArea(
        child: Observer(
          builder: (_) {
            return IndexedStack(
              index: _selectedIndex,
              children: [
                if (authStore.isLoggedIn) FollowedStreams(store: widget.followedStreamsStore),
                TopSection(topStreamsStore: widget.topStreamsStore, categoriesStore: widget.categoriesStore),
                Search(searchStore: widget.searchStore),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Observer(
        builder: (_) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
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
            currentIndex: _selectedIndex,
            onTap: _handleTap,
          );
        },
      ),
    );
  }
}

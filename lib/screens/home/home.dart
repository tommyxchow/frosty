import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/home/search/search.dart';
import 'package:frosty/screens/home/search/stores/search_store.dart';
import 'package:frosty/screens/home/stores/categories_store.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/streams_list.dart';
import 'package:frosty/screens/home/top/top_section.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final ListStore topSectionStore;
  final CategoriesStore categoriesSectionStore;
  final SearchStore searchStore;
  final ListStore? followedStreamsStore;

  const Home({
    Key? key,
    required this.topSectionStore,
    required this.categoriesSectionStore,
    required this.searchStore,
    required this.followedStreamsStore,
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
          builder: (_) {
            return IndexedStack(
              index: _selectedIndex,
              children: [
                if (authStore.isLoggedIn) StreamsList(store: widget.followedStreamsStore!),
                TopSection(
                  topSectionStore: widget.topSectionStore,
                  categoriesSectionStore: widget.categoriesSectionStore,
                ),
                Search(searchStore: widget.searchStore),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Observer(
        builder: (_) {
          return BottomNavigationBar(
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

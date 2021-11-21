import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/categories.dart';
import 'package:frosty/screens/search.dart';
import 'package:frosty/screens/settings.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/home_store.dart';
import 'package:frosty/stores/settings_store.dart';
import 'package:frosty/stores/stream_list_store.dart';
import 'package:provider/provider.dart';

import '../widgets/stream_list.dart';

class Home extends StatefulWidget {
  final HomeStore homeStore;
  final StreamListStore streamListStore;

  const Home({
    Key? key,
    required this.homeStore,
    required this.streamListStore,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _textController = TextEditingController();

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
              titles[widget.homeStore.selectedIndex],
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
            index: widget.homeStore.selectedIndex,
            children: [
              if (context.read<AuthStore>().isLoggedIn)
                StreamList(
                  category: StreamCategory.followed,
                  streamListStore: widget.streamListStore,
                ),
              StreamList(
                category: StreamCategory.top,
                streamListStore: widget.streamListStore,
              ),
              const Categories(),
              const Search(),
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
            currentIndex: widget.homeStore.selectedIndex,
            onTap: widget.homeStore.handleTap,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

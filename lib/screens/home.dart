import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/channel_list_store.dart';
import 'package:frosty/stores/home_store.dart';
import 'package:frosty/widgets/drawer_menu.dart';
import 'package:provider/provider.dart';
import 'channel_list.dart';

class Home extends StatefulWidget {
  final HomeStore homeStore;
  final ChannelListStore channelListStore;

  const Home({
    Key? key,
    required this.homeStore,
    required this.channelListStore,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final titles = [if (context.read<AuthStore>().isLoggedIn) 'Followed Channels', 'Top Channels', 'Categories'];

    debugPrint('build home');
    return Observer(
      builder: (_) {
        debugPrint('rebuild tab controller');
        return Scaffold(
          appBar: AppBar(
            title: widget.homeStore.search ? const TextField() : Text(titles[widget.homeStore.selectedIndex]),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  widget.homeStore.search = !widget.homeStore.search;
                },
              )
            ],
          ),
          drawer: const DrawerMenu(),
          body: IndexedStack(
            index: widget.homeStore.selectedIndex,
            children: [
              if (context.read<AuthStore>().isLoggedIn)
                ChannelList(
                  category: ChannelCategory.followed,
                  channelListStore: widget.channelListStore,
                ),
              ChannelList(
                category: ChannelCategory.top,
                channelListStore: widget.channelListStore,
              ),
              const Center(
                child: Text('Games'),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: BottomNavigationBar(
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
                  icon: Icon(Icons.gamepad),
                  label: 'Categories',
                ),
              ],
              currentIndex: widget.homeStore.selectedIndex,
              onTap: widget.homeStore.handleTap,
            ),
          ),
        );
      },
    );
  }
}

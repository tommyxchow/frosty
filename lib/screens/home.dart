import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/channel_list_store.dart';
import 'package:frosty/stores/home_store.dart';
import 'package:provider/provider.dart';
import 'channel_list.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeStore = HomeStore();
    final auth = context.read<AuthStore>();
    final channelListStore = ChannelListStore(auth: auth);
    final titles = [if (auth.isLoggedIn) 'Followed Channels', 'Top Channels', 'Categories'];

    debugPrint('build home');
    return Observer(
      builder: (_) {
        debugPrint('rebuild tab controller');
        return Scaffold(
          appBar: AppBar(
            title: Text(titles[homeStore.selectedIndex]),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              )
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  child: Center(
                    child: Text('Frosty for Twitch'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Settings();
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          body: IndexedStack(
            index: homeStore.selectedIndex,
            children: [
              if (auth.isLoggedIn)
                ChannelList(
                  category: ChannelCategory.followed,
                  channelListStore: channelListStore,
                ),
              ChannelList(
                category: ChannelCategory.top,
                channelListStore: channelListStore,
              ),
              const Center(
                child: Text('Games'),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: BottomNavigationBar(
              items: [
                if (auth.isLoggedIn)
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
              currentIndex: homeStore.selectedIndex,
              onTap: homeStore.handleTap,
            ),
          ),
        );
      },
    );
  }
}

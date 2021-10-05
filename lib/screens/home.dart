import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/channel_list_store.dart';
import 'package:provider/provider.dart';
import 'channel_list.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    debugPrint('build home');

    return Observer(
      builder: (_) {
        final channelListStore = ChannelListStore(auth: auth);
        debugPrint('rebuild tab controller');
        return DefaultTabController(
          length: auth.isLoggedIn ? 3 : 2,
          child: Scaffold(
            drawer: Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    child: Center(
                      child: Text('Logged in as ${auth.user?.displayName}'),
                    ),
                  ),
                  ListTile(
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
            appBar: AppBar(
              title: const Text('Frosty for Twitch'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                )
              ],
            ),
            body: TabBarView(
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
              child: TabBar(
                tabs: [
                  if (auth.isLoggedIn) const Tab(text: 'Followed'),
                  const Tab(text: 'Top'),
                  const Tab(text: 'Categories'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/channel_list_store.dart';
import 'package:get_it/get_it.dart';
import 'channel_list.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = GetIt.I<AuthStore>();
    debugPrint('build home');

    return Observer(
      builder: (_) {
        final channelListStore = ChannelListStore(auth: auth);
        debugPrint('rebuild tab controller');
        return DefaultTabController(
          length: auth.isLoggedIn ? 3 : 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Frosty for Twitch'),
              bottom: TabBar(
                tabs: [
                  const Tab(text: 'Top'),
                  if (auth.isLoggedIn) const Tab(text: 'Followed'),
                  const Tab(text: 'Categories'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
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
            body: TabBarView(
              children: [
                ChannelList(
                  category: ChannelCategory.top,
                  channelListStore: channelListStore,
                ),
                if (auth.isLoggedIn)
                  ChannelList(
                    category: ChannelCategory.followed,
                    channelListStore: channelListStore,
                  ),
                const Center(
                  child: Text('Games'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/screens/settings.dart';
import 'package:frosty/providers/channel_list_provider.dart';
import 'package:provider/provider.dart';
import 'channel_list.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthenticationProvider>();
    debugPrint('build home');

    return FutureBuilder(
      future: auth.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
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
                  const ChannelList(
                    category: Category.top,
                  ),
                  if (auth.isLoggedIn)
                    const ChannelList(
                      category: Category.followed,
                    ),
                  const Center(
                    child: Text('Games'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

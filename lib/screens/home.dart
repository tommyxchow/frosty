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
    print('build home');

    return FutureBuilder(
      future: auth.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return DefaultTabController(
            length: auth.isLoggedIn ? 3 : 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Frosty for Twitch'),
                bottom: TabBar(
                  tabs: [
                    Tab(text: 'Top'),
                    if (auth.isLoggedIn) Tab(text: 'Followed'),
                    Tab(text: 'Categories'),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Settings();
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
                    category: Category.top,
                  ),
                  if (auth.isLoggedIn)
                    ChannelList(
                      category: Category.followed,
                    ),
                  Center(
                    child: Text('Games'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

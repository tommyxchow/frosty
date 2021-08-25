import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/screens/settings.dart';
import 'package:provider/provider.dart';

import 'channel_list.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Top Channels'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Top'),
              Tab(text: 'Followed'),
              Tab(text: 'Games'),
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
        body: FutureBuilder(
          future: context.read<AuthenticationProvider>().init(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return TabBarView(
                children: [
                  ChannelList(),
                  Center(
                    child: Text('Followed'),
                  ),
                  Center(
                    child: Text('Games'),
                  ),
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

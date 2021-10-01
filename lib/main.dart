import 'package:flutter/material.dart';
import 'package:frosty/screens/home.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/channel_list_store.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthStore>(create: (_) => AuthStore()),
        ProxyProvider<AuthStore, ChannelListStore>(
          create: (_) => ChannelListStore(),
          update: (context, auth, channelListStore) {
            return ChannelListStore(id: auth.user?.id);
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final auth = context.watch<AuthStore>();
          return MaterialApp(
            title: 'Frosty',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
            ),
            home: Scaffold(
              body: FutureBuilder(
                future: auth.init(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const Home();
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

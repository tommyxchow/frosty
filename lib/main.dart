import 'package:flutter/material.dart';
import 'package:frosty/screens/home.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/stream_list_store.dart';
import 'package:frosty/stores/home_store.dart';
import 'package:frosty/stores/settings_store.dart';
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
        Provider<SettingsStore>(create: (_) => SettingsStore()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Frosty',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              canvasColor: Colors.black,
              cardColor: Colors.black,
              brightness: Brightness.dark,
            ),
            home: Scaffold(
              body: FutureBuilder(
                future: Future.wait([
                  context.read<AuthStore>().init(),
                  context.read<SettingsStore>().init(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Home(
                      streamListStore: StreamListStore(authStore: context.read<AuthStore>()),
                      homeStore: HomeStore(),
                    );
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/home/home.dart';
import 'package:frosty/screens/home/home_store.dart';
import 'package:frosty/screens/stream_list/stream_list_store.dart';
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
              primarySwatch: Colors.deepPurple,
              fontFamily: 'Inter',
              splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
              appBarTheme: const AppBarTheme(
                titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
              splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
              textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
              appBarTheme: const AppBarTheme(
                color: Colors.black,
                titleTextStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.black,
              ),
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

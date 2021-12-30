import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/categories/categories_store.dart';
import 'package:frosty/screens/home/home.dart';
import 'package:frosty/screens/home/home_store.dart';
import 'package:frosty/screens/search/search_store.dart';
import 'package:frosty/screens/stream_list/streams_followed/followed_streams_store.dart';
import 'package:frosty/screens/stream_list/streams_top/top_streams_store.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authStore = AuthStore();
  final settingsStore = SettingsStore();

  await authStore.init();
  await settingsStore.init();

  await SentryFlutter.init(
    (options) {
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      MultiProvider(
        providers: [
          Provider<AuthStore>(create: (_) => authStore),
          Provider<SettingsStore>(create: (_) => settingsStore),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authStore = context.read<AuthStore>();
    final settingsStore = context.read<SettingsStore>();

    final defaultTheme = ThemeData(
      scaffoldBackgroundColor: Colors.grey.shade900,
      brightness: Brightness.dark,
      splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        color: Colors.grey.shade900,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final oledTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
      appBarTheme: const AppBarTheme(
        color: Colors.black,
        elevation: 0.0,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
      ),
    );

    return Observer(
      builder: (context) {
        return MaterialApp(
          title: 'Frosty',
          theme: settingsStore.oledTheme ? oledTheme : defaultTheme,
          home: Home(
            homeStore: HomeStore(),
            topStreamsStore: TopStreamsStore(authStore: authStore),
            followedStreamsStore: FollowedStreamsStore(authStore: authStore),
            categoriesStore: CategoriesStore(authStore: authStore),
            searchStore: SearchStore(authStore: authStore),
          ),
        );
      },
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/home/home.dart';
import 'package:frosty/screens/home/stores/categories_store.dart';
import 'package:frosty/screens/home/stores/home_store.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/stores/search_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create and initialize the authentication store
  final authStore = AuthStore();
  await authStore.init();

  // Get the shared preferences instance and obtain the existing user settings if it exists.
  // If default settings don't exist, use an empty JSON string to use the default values.
  final preferences = await SharedPreferences.getInstance();
  final userSettings = preferences.getString('settings') ?? '{}';

  // Initialize a settings store from the settings JSON string.
  final settingsStore = SettingsStore.fromJson(jsonDecode(userSettings));

  // Create a MobX reaction that will save the settings on disk every time they are changed.
  autorun((_) => preferences.setString('settings', jsonEncode(settingsStore)));

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
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.deepPurpleAccent,
      ),
      dialogBackgroundColor: Colors.grey.shade900,
      toggleableActiveColor: Colors.deepPurpleAccent,
    );

    final oledTheme = ThemeData(
      canvasColor: Colors.black,
      splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        color: Colors.black,
        elevation: 0.0,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.deepPurpleAccent,
      ),
      dialogBackgroundColor: Colors.black,
      toggleableActiveColor: Colors.deepPurpleAccent,
    );

    return Observer(
      builder: (context) {
        return MaterialApp(
          title: 'Frosty',
          theme: settingsStore.useOledTheme ? oledTheme : defaultTheme,
          home: Home(
            homeStore: HomeStore(),
            topSectionStore: ListStore(
              authStore: authStore,
              listType: ListType.top,
            ),
            categoriesSectionStore: CategoriesStore(authStore: authStore),
            followedStreamsStore: authStore.isLoggedIn
                ? ListStore(
                    authStore: authStore,
                    listType: ListType.followed,
                  )
                : null,
            searchStore: SearchStore(authStore: authStore),
          ),
        );
      },
    );
  }
}

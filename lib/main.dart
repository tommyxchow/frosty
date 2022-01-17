import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/api/bttv_api.dart';
import 'package:frosty/api/ffz_api.dart';
import 'package:frosty/api/seventv_api.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/home/home.dart';
import 'package:frosty/screens/home/stores/categories_store.dart';
import 'package:frosty/screens/home/stores/home_store.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/stores/search_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:http/http.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the shared preferences instance and obtain the existing user settings if it exists.
  // If default settings don't exist, use an empty JSON string to use the default values.
  final preferences = await SharedPreferences.getInstance();
  final userSettings = preferences.getString('settings') ?? '{}';

  // Initialize a settings store from the settings JSON string.
  final settingsStore = SettingsStore.fromJson(jsonDecode(userSettings));

  // Create a MobX reaction that will save the settings on disk every time they are changed.
  autorun((_) => preferences.setString('settings', jsonEncode(settingsStore)));

  if (settingsStore.sendCrashLogs) {
    await SentryFlutter.init((options) => options.tracesSampleRate = sampleRate);
  }

  /// Initialize API services with a common client.
  /// This will prevent every request from creating a new client instance.
  final client = Client();
  final twitchApiService = TwitchApi(client);
  final bttvApiService = BTTVApi(client);
  final ffzApiService = FFZApi(client);
  final sevenTVApiService = SevenTVApi(client);

  // Create and initialize the authentication store
  final authStore = AuthStore(twitchApi: twitchApiService);
  await authStore.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthStore>(create: (_) => authStore),
        Provider<SettingsStore>(create: (_) => settingsStore),
        Provider<TwitchApi>(create: (_) => twitchApiService),
        Provider<BTTVApi>(create: (_) => bttvApiService),
        Provider<FFZApi>(create: (_) => ffzApiService),
        Provider<SevenTVApi>(create: (_) => sevenTVApiService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        elevation: 0.0,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.deepPurpleAccent,
      ),
      toggleableActiveColor: Colors.deepPurpleAccent,
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
      ),
    );

    final darkTheme = ThemeData(
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
        final authStore = context.read<AuthStore>();
        final settingsStore = context.read<SettingsStore>();
        final twitchApi = context.read<TwitchApi>();

        return MaterialApp(
          title: 'Frosty',
          theme: lightTheme,
          darkTheme: settingsStore.themeType == ThemeType.dark || settingsStore.themeType == ThemeType.system ? darkTheme : oledTheme,
          themeMode: settingsStore.themeType == ThemeType.system
              ? ThemeMode.system
              : settingsStore.themeType == ThemeType.light
                  ? ThemeMode.light
                  : ThemeMode.dark,
          home: Home(
            homeStore: HomeStore(),
            followedStreamsStore: authStore.isLoggedIn
                ? ListStore(
                    authStore: authStore,
                    twitchApi: twitchApi,
                    listType: ListType.followed,
                  )
                : null,
            topSectionStore: ListStore(
              authStore: authStore,
              twitchApi: twitchApi,
              listType: ListType.top,
            ),
            categoriesSectionStore: CategoriesStore(
              authStore: authStore,
              twitchApi: twitchApi,
            ),
            searchStore: SearchStore(
              authStore: authStore,
              twitchApi: twitchApi,
            ),
          ),
        );
      },
    );
  }
}

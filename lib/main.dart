import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/screens/home/home.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:http/http.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Workaround for clearing stored tokens on uninstall.
  // If first time running app, will clear all tokens in the secure storage.
  if (prefs.getBool('first_run') != false) {
    debugPrint('Clearing secure storage...');
    const storage = FlutterSecureStorage();

    await storage.deleteAll();
  }

  // With the shared preferences instance, obtain the existing user settings if it exists.
  // If default settings don't exist, use an empty JSON string to use the default values.
  final userSettings = prefs.getString('settings') ?? '{}';

  // Initialize a settings store from the settings JSON string.
  final settingsStore = SettingsStore.fromJson(jsonDecode(userSettings));

  // Create a MobX reaction that will save the settings on disk every time they are changed.
  autorun((_) => prefs.setString('settings', jsonEncode(settingsStore)));

  // Initialize Sentry for crash reporting if enabled.
  if (settingsStore.sendCrashLogs) await SentryFlutter.init((options) => options.tracesSampleRate = sampleRate);

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

// Navigator key for sleep timer. Allows navigation popping without context.
final navigatorKey = GlobalKey<NavigatorState>();

const gray = Color.fromRGBO(22, 22, 22, 1.0);
const purple = Color(0xff9146ff);

const inputTheme = InputDecorationTheme(
  filled: true,
  contentPadding: EdgeInsets.all(10.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
    borderSide: BorderSide(style: BorderStyle.none),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
    borderSide: BorderSide(style: BorderStyle.none),
  ),
  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
    borderSide: BorderSide(style: BorderStyle.none),
  ),
);

final lightTheme = ThemeData(
  canvasColor: Colors.white,
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
    accentColor: purple,
  ),
  toggleableActiveColor: purple,
  tabBarTheme: const TabBarTheme(
    labelColor: Colors.black,
    unselectedLabelColor: Colors.grey,
  ),
  inputDecorationTheme: inputTheme,
);

final darkTheme = ThemeData(
  canvasColor: gray,
  brightness: Brightness.dark,
  splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
  fontFamily: 'Inter',
  appBarTheme: const AppBarTheme(
    color: gray,
    elevation: 0.0,
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: gray),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
    accentColor: purple,
  ),
  dialogBackgroundColor: gray,
  toggleableActiveColor: purple,
  inputDecorationTheme: inputTheme,
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
    accentColor: purple,
  ),
  dialogBackgroundColor: Colors.black,
  toggleableActiveColor: purple,
  inputDecorationTheme: inputTheme,
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final settingsStore = context.read<SettingsStore>();

        return MaterialApp(
          title: 'Frosty',
          theme: lightTheme,
          darkTheme: settingsStore.themeType == ThemeType.dark || settingsStore.themeType == ThemeType.system ? darkTheme : oledTheme,
          themeMode: settingsStore.themeType == ThemeType.system
              ? ThemeMode.system
              : settingsStore.themeType == ThemeType.light
                  ? ThemeMode.light
                  : ThemeMode.dark,
          home: const Home(),
          navigatorKey: navigatorKey,
        );
      },
    );
  }
}

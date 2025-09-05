import 'dart:convert';

import 'package:advanced_in_app_review/advanced_in_app_review.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/dio_client.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/apis/twitch_auth_interceptor.dart';
import 'package:frosty/apis/unauthorized_interceptor.dart';
import 'package:frosty/cache_manager.dart';
import 'package:frosty/firebase_options.dart';
import 'package:frosty/screens/home/home.dart';
import 'package:frosty/screens/onboarding/onboarding_intro.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CustomCacheManager.removeOrphanedCacheFiles();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final prefs = await SharedPreferences.getInstance();

  final firstRun = prefs.getBool('first_run') ?? true;

  // Workaround for clearing stored tokens on uninstall.
  // If first time running app, will clear all tokens in the secure storage.
  if (firstRun) {
    debugPrint('Clearing secure storage...');
    const storage = FlutterSecureStorage();

    await storage.deleteAll();
  }

  await initUtils();

  // With the shared preferences instance, obtain the existing user settings if it exists.
  // If default settings don't exist, use an empty JSON string to use the default values.
  final userSettings = prefs.getString('settings') ?? '{}';

  // Initialize a settings store from the settings JSON string.
  final settingsStore = SettingsStore.fromJson(jsonDecode(userSettings));

  // Create a MobX reaction that will save the settings on disk every time they are changed.
  autorun((_) => prefs.setString('settings', jsonEncode(settingsStore)));

  /// Initialize API services with a common Dio client.
  /// This will prevent every request from creating a new client instance.
  final dioClient = DioClient.createClient();

  // Create API services
  final twitchApiService = TwitchApi(dioClient);
  final bttvApiService = BTTVApi(dioClient);
  final ffzApiService = FFZApi(dioClient);
  final sevenTVApiService = SevenTVApi(dioClient);

  // Create and initialize the authentication store
  final authStore = AuthStore(twitchApi: twitchApiService);

  // Add the auth interceptor to the Dio client after AuthStore creation
  dioClient.interceptors.add(TwitchAuthInterceptor(authStore));

  // Add the unauthorized interceptor to catch 401 errors
  dioClient.interceptors.add(UnauthorizedInterceptor(authStore));

  await authStore.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthStore>.value(value: authStore),
        Provider<SettingsStore>.value(value: settingsStore),
        Provider<TwitchApi>.value(value: twitchApiService),
        Provider<BTTVApi>.value(value: bttvApiService),
        Provider<FFZApi>.value(value: ffzApiService),
        Provider<SevenTVApi>.value(value: sevenTVApiService),
      ],
      child: MyApp(firstRun: firstRun),
    ),
  );
}

// Navigator key for sleep timer. Allows navigation popping without context.
final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final bool firstRun;

  const MyApp({
    super.key,
    this.firstRun = false,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    AdvancedInAppReview()
        .setMinDaysBeforeRemind(7)
        .setMinDaysAfterInstall(1)
        .setMinLaunchTimes(5)
        .setMinSecondsBeforeShowDialog(3)
        .monitor();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final settingsStore = context.read<SettingsStore>();
        final themes =
            FrostyThemes(colorSchemeSeed: Color(settingsStore.accentColor));

        return Provider<FrostyThemes>(
          create: (_) => themes,
          child: MaterialApp(
            title: 'Frosty',
            theme: themes.light,
            darkTheme: themes.dark,
            themeMode: settingsStore.themeType == ThemeType.system
                ? ThemeMode.system
                : settingsStore.themeType == ThemeType.light
                    ? ThemeMode.light
                    : ThemeMode.dark,
            home: widget.firstRun ? const OnboardingIntro() : const Home(),
            navigatorKey: navigatorKey,
          ),
        );
      },
    );
  }
}

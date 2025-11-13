import 'dart:async';
import 'dart:convert';

import 'package:advanced_in_app_review/advanced_in_app_review.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/cache_manager.dart';
import 'package:frosty/firebase_options.dart';
import 'package:frosty/screens/channel/channel.dart';
import 'package:frosty/screens/home/home.dart';
import 'package:frosty/screens/onboarding/onboarding_intro.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:http/http.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    AdvancedInAppReview()
        .setMinDaysBeforeRemind(7)
        .setMinDaysAfterInstall(1)
        .setMinLaunchTimes(5)
        .setMinSecondsBeforeShowDialog(3)
        .monitor();

    _initDeepLinks();
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

  Future<void> _initDeepLinks() async {
    try {
      // Handle links when app is already open
      _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
        handleDeepLink(uri);
      });

      // Handle the initial link if app was opened from a link
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Failed to initialize deep links: $e');
    }
  }

  Future<void> handleDeepLink(Uri uri) async {
    final failureSnackbar = SnackBar(
      content: AlertMessage(
        message: 'Unable to navigate to \'$uri\'',
        centered: false,
        trailingIcon: Icons.open_in_browser_rounded,
        // Fallback, allow user to open URL outside app
        onTrailingIconPressed: () async {
          await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView, // Force browser
          );
        },
      ),
    );

    // Handle channel links
    if (uri.pathSegments.isNotEmpty) {
      final channelName = uri.pathSegments.first;

      try {
        final twitchApi = context.read<TwitchApi>();
        final authStore = context.read<AuthStore>();

        final user = await twitchApi.getUser(
          userLogin: channelName,
          headers: authStore.headersTwitch,
        );

        final route = MaterialPageRoute(
          builder: (context) => VideoChat(
            userId: user.id,
            userName: user.displayName,
            userLogin: user.login,
          ),
        );

        if (navigatorKey.currentState == null) return;

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => navigatorKey.currentState?.push(route),
        );
      } catch (e) {
        // If we get here, there was most likely an error with the Twitch API call and/or this isn't really a channel link
        debugPrint('Failed to open link $uri due to error: $e');

        if (navigatorKey.currentContext == null) return;
        ScaffoldMessenger.of(navigatorKey.currentContext!)
            .showSnackBar(failureSnackbar);
      }
    }
    // TODO: Here we can implement handlers for other types of links
    else {
      // If we get here, it's a link format that we're unable to handle
      if (navigatorKey.currentContext == null) return;
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(failureSnackbar);
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}

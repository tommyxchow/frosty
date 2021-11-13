import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosty/screens/home.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/stream_list_store.dart';
import 'package:frosty/stores/home_store.dart';
import 'package:frosty/stores/settings_store.dart';
import 'package:google_fonts/google_fonts.dart';
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
              fontFamily: GoogleFonts.inter().fontFamily,
              splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
              appBarTheme: AppBarTheme(
                titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: Colors.black,
                splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
                textTheme: ThemeData.dark().textTheme.apply(fontFamily: GoogleFonts.inter().fontFamily),
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.deepPurple,
                ),
                appBarTheme: AppBarTheme(
                  color: Colors.black,
                  titleTextStyle: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Colors.black,
                )),
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

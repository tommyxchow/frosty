import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/providers/settings_provider.dart';
import 'package:frosty/screens/home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Frosty',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        home: Home(),
      ),
    );
  }
}

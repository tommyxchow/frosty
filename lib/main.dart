import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/providers/settings_provider.dart';
import 'package:frosty/screens/home.dart';
import 'package:frosty/providers/channel_list_provider.dart';
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
        ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
        ChangeNotifierProxyProvider<AuthenticationProvider, SettingsProvider>(
          create: (_) => SettingsProvider(),
          update: (context, auth, settingsProvider) {
            return SettingsProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, ChannelListProvider>(
          create: (_) => ChannelListProvider(),
          update: (context, auth, channelListProvider) {
            return ChannelListProvider(id: auth.user?.id);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Frosty',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        home: const Home(),
      ),
    );
  }
}

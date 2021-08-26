import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/providers/settings_provider.dart';
import 'package:frosty/screens/home.dart';
import 'package:frosty/providers/channel_list_provider.dart';
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
        ChangeNotifierProxyProvider<AuthenticationProvider, SettingsProvider>(
          create: (_) => SettingsProvider(),
          update: (context, auth, settingsProvider) {
            return SettingsProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthenticationProvider, ChannelListProvider>(
          create: (_) => ChannelListProvider(token: null),
          update: (context, auth, channelListProvider) {
            print(auth.token);
            return ChannelListProvider(token: auth.token, id: auth.user?.id);
          },
        ),
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

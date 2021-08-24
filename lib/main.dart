import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/screens/channel_list.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Authentication>(create: (_) => Authentication()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Frosty',
            theme: ThemeData(
              primaryColor: Colors.purple.shade900,
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
            ),
            home: Scaffold(
              appBar: AppBar(
                title: Text('Top Channels'),
              ),
              body: FutureBuilder(
                future: context.read<Authentication>().init(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ChannelList();
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

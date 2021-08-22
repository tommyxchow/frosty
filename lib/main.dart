import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/widgets/channel_list.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<Authentication>(create: (context) => Authentication()),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text('Top Channels'),
          ),
          body: ChannelList(),
        ),
      ),
    );
  }
}

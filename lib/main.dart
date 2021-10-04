import 'package:flutter/material.dart';
import 'package:frosty/screens/home.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:get_it/get_it.dart';

void main() {
  GetIt.I.registerSingleton<AuthStore>(AuthStore());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = GetIt.I<AuthStore>();
    return MaterialApp(
      title: 'Frosty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        body: FutureBuilder(
          future: auth.init(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const Home();
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

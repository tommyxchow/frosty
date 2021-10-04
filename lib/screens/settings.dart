import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:get_it/get_it.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('settings');
    final auth = GetIt.I<AuthStore>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Observer(
        builder: (_) {
          return Center(
            child: ElevatedButton(
              child: auth.isLoggedIn ? Text(auth.user!.displayName) : const Text('Login'),
              onPressed: () => auth.isLoggedIn ? auth.logout() : auth.login(),
            ),
          );
        },
      ),
    );
  }
}

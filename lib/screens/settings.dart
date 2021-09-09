import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AuthenticationProvider>(
      builder: (context, settings, auth, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: Center(
            child: ElevatedButton(
              child: auth.isLoggedIn ? Text(auth.user!.displayName) : const Text('Login'),
              onPressed: () => auth.isLoggedIn ? auth.logout() : auth.login(),
            ),
          ),
        );
      },
    );
  }
}

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
            title: Text('Settings'),
          ),
          body: Center(
            child: TextButton(
              child: auth.isLoggedIn ? Text(auth.user!.displayName) : Text('Login'),
              onPressed: () {
                auth.isLoggedIn ? auth.logout() : auth.login();
              },
            ),
          ),
        );
      },
    );
  }
}

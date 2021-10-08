import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/settings_store.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('settings');
    final auth = context.read<AuthStore>();
    final settings = context.read<SettingsStore>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Observer(
        builder: (_) {
          return ListView(
            children: [
              ElevatedButton(
                child: auth.isLoggedIn ? Text(auth.user!.displayName) : const Text('Login'),
                onPressed: () => auth.isLoggedIn ? auth.logout() : auth.login(),
              ),
              SwitchListTile(
                title: const Text('Enable Video'),
                value: settings.videoEnabled,
                onChanged: (newValue) => settings.videoEnabled = newValue,
              ),
            ],
          );
        },
      ),
    );
  }
}

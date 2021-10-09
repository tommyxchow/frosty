import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/settings_store.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authStore = context.read<AuthStore>();
    final settingsStore = context.read<SettingsStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Observer(
        builder: (_) {
          return ListView(
            children: [
              ElevatedButton(
                child: authStore.isLoggedIn ? Text(authStore.user!.displayName) : const Text('Login'),
                onPressed: () => authStore.isLoggedIn ? authStore.logout() : authStore.login(),
              ),
              SwitchListTile(
                title: const Text('Enable Video'),
                value: settingsStore.videoEnabled,
                onChanged: (newValue) => settingsStore.videoEnabled = newValue,
              ),
            ],
          );
        },
      ),
    );
  }
}

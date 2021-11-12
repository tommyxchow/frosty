import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/settings_store.dart';
import 'package:frosty/widgets/profile_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  final SettingsStore settingsStore;

  const Settings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: Observer(
        builder: (_) {
          return ListView(
            children: [
              ProfileCard(authStore: context.read<AuthStore>()),
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

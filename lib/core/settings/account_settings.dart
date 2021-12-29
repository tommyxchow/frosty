import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/profile_card.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';

class AccountSettings extends StatelessWidget {
  final SettingsStore settingsStore;
  final AuthStore authStore;

  const AccountSettings({
    Key? key,
    required this.settingsStore,
    required this.authStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('ACCOUNT'),
            ProfileCard(authStore: authStore),
          ],
        );
      },
    );
  }
}

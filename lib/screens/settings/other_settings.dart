import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';

class OtherSettings extends StatelessWidget {
  final SettingsStore settingsStore;
  const OtherSettings({
    Key? key,
    required this.settingsStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Other'),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'Frosty for Twitch',
            applicationVersion: '1.0.0',
            applicationLegalese: '\u{a9} 2021 Tommy Chow',
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          width: double.infinity,
          child: OutlinedButton(
            child: const Text('Clear Image Cache'),
            onPressed: () async {
              await DefaultCacheManager().emptyCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image cache cleared!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

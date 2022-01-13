import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
            applicationName: 'Frosty',
            applicationVersion: appVersion,
            applicationLegalese: '\u{a9} 2022 Tommy Chow',
          ),
        ),
        Observer(
          builder: (_) => SwitchListTile.adaptive(
            title: const Text('Send anonymous crash logs'),
            value: settingsStore.sendCrashLogs,
            onChanged: (newValue) {
              if (newValue == true) {
                SentryFlutter.init((options) => options.tracesSampleRate = sampleRate);
              } else {
                Sentry.close();
              }
              settingsStore.sendCrashLogs = newValue;
            },
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

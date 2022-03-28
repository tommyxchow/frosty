import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherSettings extends StatelessWidget {
  final SettingsStore settingsStore;
  const OtherSettings({
    Key? key,
    required this.settingsStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.miscellaneous_services),
      title: const Text(
        'Other',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About Frosty'),
          onTap: () async {
            final packageInfo = await PackageInfo.fromPlatform();

            showAboutDialog(
              context: context,
              applicationName: packageInfo.appName,
              applicationVersion: 'Version ${packageInfo.version} (${packageInfo.buildNumber})',
              applicationLegalese: '\u{a9} 2022 Tommy Chow',
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.launch),
          title: const Text('FAQ'),
          onTap: () => launch('https://github.com/tommyxchow/frosty#faq'),
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
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Clear Image Cache'),
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

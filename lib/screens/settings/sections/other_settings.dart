import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Future<void> _showConfirmDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text('Are you reset all settings?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              settingsStore.reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Yes'),
            style: TextButton.styleFrom(primary: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.help),
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
              applicationIcon: SvgPicture.asset(
                'assets/icons/logo.svg',
                height: 80,
              ),
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
            title: const Text('Send Anonymous Crash Logs'),
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
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.restore),
            label: const Text('Reset All Settings'),
            onPressed: () => _showConfirmDialog(context),
          ),
        ),
      ],
    );
  }
}

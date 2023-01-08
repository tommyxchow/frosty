import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherSettings extends StatefulWidget {
  final SettingsStore settingsStore;

  const OtherSettings({
    Key? key,
    required this.settingsStore,
  }) : super(key: key);

  @override
  State<OtherSettings> createState() => _OtherSettingsState();
}

class _OtherSettingsState extends State<OtherSettings> {
  Future<void> _showConfirmDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Reset All Settings',
        content: const Text('Are you sure you want to reset all settings?'),
        actions: [
          Button(
            onPressed: () {
              HapticFeedback.heavyImpact();

              widget.settingsStore.resetAllSettings();

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: AlertMessage(message: 'All settings reset'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Yes'),
          ),
          Button(
            fill: true,
            onPressed: Navigator.of(context).pop,
            color: Colors.red.shade700,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          title: const Text('Changelog'),
          onTap: () => launchUrl(Uri.parse('https://github.com/tommyxchow/frosty/releases'),
              mode: widget.settingsStore.launchUrlExternal ? LaunchMode.externalApplication : LaunchMode.inAppWebView),
        ),
        ListTile(
          leading: const Icon(Icons.launch),
          title: const Text('FAQ'),
          onTap: () => launchUrl(Uri.parse('https://github.com/tommyxchow/frosty#faq'),
              mode: widget.settingsStore.launchUrlExternal ? LaunchMode.externalApplication : LaunchMode.inAppWebView),
        ),
        Observer(
          builder: (_) => SwitchListTile.adaptive(
            title: const Text('Send anonymous crash logs'),
            isThreeLine: true,
            subtitle: const Text('Help improve Frosty by sending anonymous crash logs through Sentry.io.'),
            value: widget.settingsStore.sendCrashLogs,
            onChanged: (newValue) {
              if (newValue == true) {
                SentryFlutter.init((options) => options.tracesSampleRate = sampleRate);
              } else {
                Sentry.close();
              }
              widget.settingsStore.sendCrashLogs = newValue;
            },
          ),
        ),
        ...[
          Button(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            icon: const Icon(Icons.delete_sweep),
            child: const Text('Clear image cache'),
            onPressed: () async {
              HapticFeedback.mediumImpact();

              await DefaultCacheManager().emptyCache();

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: AlertMessage(message: 'Image cache cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          Button(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            onPressed: () => _showConfirmDialog(context),
            icon: const Icon(Icons.restore),
            child: const Text('Reset all settings'),
          )
        ].map(
          (button) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 5.0,
            ),
            width: double.infinity,
            child: button,
          ),
        ),
      ],
    );
  }
}

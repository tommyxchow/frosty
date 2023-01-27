import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:frosty/widgets/list_tile.dart';
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
        message: 'Are you sure you want to reset all settings?',
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
            onPressed: Navigator.of(context).pop,
            color: Colors.grey,
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
        FrostyListTile(
          leading: const Icon(Icons.info_outline_rounded),
          title: 'About Frosty',
          onTap: () async {
            final packageInfo = await PackageInfo.fromPlatform();

            if (!mounted) return;

            showAboutDialog(
              context: context,
              applicationIcon: SvgPicture.asset(
                'assets/icons/logo.svg',
                height: 80,
              ),
              applicationName: packageInfo.appName,
              applicationVersion: 'Version ${packageInfo.version} (${packageInfo.buildNumber})',
              applicationLegalese: '\u{a9} 2023 Tommy Chow',
            );
          },
        ),
        FrostyListTile(
          leading: const Icon(Icons.launch_rounded),
          title: 'Changelog',
          onTap: () => launchUrl(Uri.parse('https://github.com/tommyxchow/frosty/releases'),
              mode: widget.settingsStore.launchUrlExternal ? LaunchMode.externalApplication : LaunchMode.inAppWebView),
        ),
        FrostyListTile(
          leading: const Icon(Icons.launch_rounded),
          title: 'FAQ',
          onTap: () => launchUrl(Uri.parse('https://www.frostyapp.io/#faq'),
              mode: widget.settingsStore.launchUrlExternal ? LaunchMode.externalApplication : LaunchMode.inAppWebView),
        ),
        FrostyListTile(
          leading: const Icon(Icons.delete_outline_rounded),
          title: 'Clear image cache',
          onTap: () async {
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
        FrostyListTile(
          leading: const Icon(Icons.restore_rounded),
          title: 'Reset settings',
          onTap: () => _showConfirmDialog(context),
        ),
        Observer(
          builder: (_) => SettingsListSwitch(
            title: 'Send anonymous crash logs',
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
      ],
    );
  }
}

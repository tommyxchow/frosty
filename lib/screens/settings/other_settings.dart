import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frosty/cache_manager.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/release_notes.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherSettings extends StatefulWidget {
  final SettingsStore settingsStore;

  const OtherSettings({
    super.key,
    required this.settingsStore,
  });

  @override
  State<OtherSettings> createState() => _OtherSettingsState();
}

class _OtherSettingsState extends State<OtherSettings> {
  Future<void> _showConfirmDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Reset all settings'),
        content: const Text('Are you sure you want to reset all settings?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();

              widget.settingsStore.resetAllSettings();

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: AlertMessage(
                    message: 'All settings reset',
                    centered: false,
                  ),
                ),
              );
            },
            child: const Text('Yes'),
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
          leading: const Icon(Icons.info_outline_rounded),
          title: const Text('About Frosty'),
          onTap: () async {
            final packageInfo = await PackageInfo.fromPlatform();

            if (!context.mounted) return;

            showAboutDialog(
              context: context,
              applicationIcon: SvgPicture.asset(
                'assets/icons/logo.svg',
                height: 80,
              ),
              applicationName: packageInfo.appName,
              applicationVersion:
                  'Version ${packageInfo.version} (${packageInfo.buildNumber})',
              applicationLegalese: '\u{a9} 2025 Tommy Chow',
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.notes_rounded),
          title: const Text('Release notes'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ReleaseNotes(),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.launch_rounded),
          title: const Text('FAQ'),
          onTap: () => launchUrl(
            Uri.parse('https://www.frostyapp.io/#faq'),
            mode: widget.settingsStore.launchUrlExternal
                ? LaunchMode.externalApplication
                : LaunchMode.inAppBrowserView,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline_rounded),
          title: const Text('Clear image cache'),
          onTap: () async {
            HapticFeedback.mediumImpact();

            await CustomCacheManager.instance.emptyCache();
            await CustomCacheManager.removeOrphanedCacheFiles();

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AlertMessage(
                  message: 'Image cache cleared',
                  centered: false,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.restore_rounded),
          title: const Text('Reset settings'),
          onTap: () => _showConfirmDialog(context),
        ),
        Observer(
          builder: (_) => SettingsListSwitch(
            title: 'Share crash logs and analytics',
            subtitle: const Text(
              'Help improve Frosty by sending anonymous crash logs and analytics through Firebase.',
            ),
            value: widget.settingsStore.shareCrashLogsAndAnalytics,
            onChanged: (newValue) {
              widget.settingsStore.shareCrashLogsAndAnalytics = newValue;

              FirebaseCrashlytics.instance
                  .setCrashlyticsCollectionEnabled(newValue);
              FirebaseAnalytics.instance
                  .setAnalyticsCollectionEnabled(newValue);
              FirebasePerformance.instance
                  .setPerformanceCollectionEnabled(newValue);
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/screens/settings/account/widgets/profile_card.dart';
import 'package:frosty/screens/settings/chat_settings.dart';
import 'package:frosty/screens/settings/general_settings.dart';
import 'package:frosty/screens/settings/other_settings.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/video_settings.dart';
import 'package:frosty/screens/settings/widgets/settings_tile_route.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:frosty/widgets/frosty_scrollbar.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  final SettingsStore settingsStore;

  const Settings({super.key, required this.settingsStore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: Navigator.of(context).pop,
        ),
        title: const Text('Settings'),
        actions: [
          IconButton(
              tooltip: 'Support Frosty',
              onPressed: () => launchUrl(
                Uri.parse('https://www.buymeacoffee.com/tommychow'),
                mode: settingsStore.launchUrlExternal
                    ? LaunchMode.externalApplication
                    : LaunchMode.inAppBrowserView,
              ),
              icon: const Icon(SimpleIcons.buymeacoffee),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'View source on GitHub',
              onPressed: () => launchUrl(
                Uri.parse('https://github.com/tommyxchow/frosty'),
                mode: settingsStore.launchUrlExternal
                    ? LaunchMode.externalApplication
                    : LaunchMode.inAppBrowserView,
              ),
              icon: const Icon(SimpleIcons.github),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main scrollable content
          FrostyScrollbar(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        8,
                  ),
                  sliver: SliverList.list(
                    children: [
                      const SectionHeader('Account', isFirst: true),
                      ProfileCard(authStore: context.read<AuthStore>()),
                      const SectionHeader('Customize'),
                      SettingsTileRoute(
                        leading: const Icon(Icons.settings_outlined),
                        title: 'General',
                        child: GeneralSettings(settingsStore: settingsStore),
                      ),
                      SettingsTileRoute(
                        leading: const Icon(Icons.tv_rounded),
                        title: 'Video',
                        child: VideoSettings(settingsStore: settingsStore),
                      ),
                      SettingsTileRoute(
                        leading: const Icon(Icons.chat_outlined),
                        title: 'Chat',
                        child: ChatSettings(settingsStore: settingsStore),
                      ),
                      const SectionHeader('Other'),
                      OtherSettings(settingsStore: settingsStore),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.data?.version ?? '';
                        final buildNumber = snapshot.data?.buildNumber ?? '';
                        final mutedColor = theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5);
                        return Padding(
                          padding: EdgeInsets.only(
                            top: 16,
                            bottom: MediaQuery.of(context).padding.bottom,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text.rich(
                                TextSpan(
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: mutedColor,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Made by '),
                                    WidgetSpan(
                                      alignment:
                                          PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: GestureDetector(
                                        onTap: () => launchUrl(
                                          Uri.parse(
                                            'https://tommychow.com',
                                          ),
                                          mode: settingsStore
                                                  .launchUrlExternal
                                              ? LaunchMode
                                                  .externalApplication
                                              : LaunchMode
                                                  .inAppBrowserView,
                                        ),
                                        child: Text(
                                          'Tommy Chow',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: mutedColor,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: mutedColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (snapshot.hasData)
                                GestureDetector(
                                  onTap: () => launchUrl(
                                    Uri.parse(
                                      'https://github.com/tommyxchow/frosty/releases/tag/v$version',
                                    ),
                                    mode: settingsStore.launchUrlExternal
                                        ? LaunchMode.externalApplication
                                        : LaunchMode.inAppBrowserView,
                                  ),
                                  child: Text(
                                    'v$version ($buildNumber)',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: mutedColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Blurred app bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredContainer(
              gradientDirection: GradientDirection.up,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: MediaQuery.of(context).padding.left,
                right: MediaQuery.of(context).padding.right,
              ),
              child: const SizedBox(height: kToolbarHeight),
            ),
          ),
        ],
      ),
    );
  }
}

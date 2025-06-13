import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/home_store.dart';
import 'package:frosty/screens/home/search/search.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/home/stream_list/streams_list.dart';
import 'package:frosty/screens/home/top/top.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/release_notes.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final _authStore = context.read<AuthStore>();

  late final _homeStore = HomeStore(authStore: _authStore);

  Future<void> checkAndShowReleaseNotes() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();

    final currentVersion = packageInfo.version;
    final storedVersion = prefs.getString('last_shown_version');

    // Extract major.minor version (ignore patch)
    final currentMajorMinor = currentVersion.split('.').take(2).join('.');
    final storedMajorMinor = storedVersion?.split('.').take(2).join('.');

    if (storedMajorMinor == null || storedMajorMinor != currentMajorMinor) {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReleaseNotes()),
      ).then((_) => prefs.setString('last_shown_version', currentVersion));
    }
  }

  @override
  void initState() {
    super.initState();
    checkAndShowReleaseNotes();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([]);

    final isLoggedIn = _authStore.isLoggedIn && _authStore.user.details != null;

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          shape: const Border(),
          title: Observer(
            builder: (_) {
              final titles = [
                if (_authStore.isLoggedIn) 'Following',
                'Top',
                'Search',
              ];

              return Text(titles[_homeStore.selectedIndex]);
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Settings',
                icon: isLoggedIn
                    ? ProfilePicture(
                        userLogin: _authStore.user.details!.login,
                        radius: 16,
                      )
                    : const Icon(Icons.settings_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Settings(settingsStore: context.read<SettingsStore>()),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Observer(
            builder: (_) => IndexedStack(
              index: _homeStore.selectedIndex,
              children: [
                if (_authStore.isLoggedIn)
                  StreamsList(
                    listType: ListType.followed,
                    scrollController: _homeStore.followedScrollController,
                  ),
                TopSection(
                  homeStore: _homeStore,
                ),
                Search(
                  scrollController: _homeStore.searchScrollController,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            Observer(
              builder: (_) => NavigationBar(
                destinations: [
                  if (_authStore.isLoggedIn)
                    const NavigationDestination(
                      icon: Icon(
                        Icons.favorite_border_rounded,
                      ),
                      selectedIcon: Icon(Icons.favorite_rounded),
                      label: 'Following',
                      tooltip: 'Following',
                    ),
                  const NavigationDestination(
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                    ),
                    selectedIcon: Icon(Icons.arrow_upward_rounded),
                    label: 'Top',
                    tooltip: 'Top',
                  ),
                  const NavigationDestination(
                    icon: Icon(
                      Icons.search_rounded,
                    ),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: 'Search',
                    tooltip: 'Search',
                  ),
                ],
                selectedIndex: _homeStore.selectedIndex,
                onDestinationSelected: _homeStore.handleTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeStore.dispose();
    super.dispose();
  }
}

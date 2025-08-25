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
import 'package:frosty/widgets/animated_scroll_border.dart';
import 'package:frosty/widgets/blurred_container.dart';
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
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
          flexibleSpace: Observer(
            builder: (_) {
              // Only show flexible space on Following tab
              final isOnFollowingTab =
                  isLoggedIn && _homeStore.selectedIndex == 0;

              // Only show flexible space when on Following tab
              if (!isOnFollowingTab) return const SizedBox.shrink();

              return BlurredContainer(
                child: Column(
                  children: [
                    const Expanded(child: SizedBox.expand()),
                    AnimatedScrollBorder(
                      scrollController: _homeStore.followedScrollController,
                    ),
                  ],
                ),
              );
            },
          ),
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
        body: Observer(
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
        bottomNavigationBar: BlurredContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Observer(
                builder: (_) {
                  ScrollController scrollController;
                  if (isLoggedIn && _homeStore.selectedIndex == 0) {
                    // Following tab
                    scrollController = _homeStore.followedScrollController;
                  } else if (_homeStore.selectedIndex == (isLoggedIn ? 1 : 0)) {
                    // Top tab
                    scrollController = _homeStore.topSectionScrollControllers[
                        _homeStore.topSectionCurrentIndex];
                  } else {
                    // Search tab
                    scrollController = _homeStore.searchScrollController;
                  }

                  return AnimatedScrollBorder(
                    scrollController: scrollController,
                    position: ScrollBorderPosition.bottom,
                  );
                },
              ),
              Observer(
                builder: (_) => NavigationBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
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
      ),
    );
  }

  @override
  void dispose() {
    _homeStore.dispose();
    super.dispose();
  }
}

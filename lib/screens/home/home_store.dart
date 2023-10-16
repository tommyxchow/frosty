import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

/// The home store that handles scrolling and navigating between tabs on the home screen.
class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  final AuthStore authStore;

  /// The scroll controller for controlling the scroll to top on the followed section.
  final followedScrollController = ScrollController();

  /// The scroll controllers for controlling the scroll to top on the top section.
  /// One controller is for the top streams tab and the other is for the top categories tab.
  final topSectionScrollControllers = [
    ScrollController(),
    ScrollController(),
  ];

  /// The scroll controller for controlling the scroll to top on the search section.
  final searchScrollController = ScrollController();

  /// The current index of the top section tab. Changes when switching between the streams and categories tabs.
  var topSectionCurrentIndex = 0;

  /// The current selected index/tab of the bottom navigation bar.
  @readonly
  var _selectedIndex = 0;

  late final ReactionDisposer _disposeReaction;
  HomeStoreBase({required this.authStore}) {
    // Setup a reaction that will return to the first tab when logging in/out.
    // This will prevent an out of range index error when last visiting the search screen and logging out.
    _disposeReaction = reaction(
      (_) => authStore.isLoggedIn,
      (_) => _selectedIndex = 0,
    );
  }

  @action
  void handleTap(int index) {
    // If tapping a different tab, set the new index to show.
    if (index != _selectedIndex) {
      _selectedIndex = index;
    } else {
      const duration = Duration(milliseconds: 300);

      // Use different logic if logged in/out since there will be one less tab when logged out.
      if (authStore.isLoggedIn) {
        if (index == 0 && followedScrollController.hasClients) {
          // If on the followed tab and tapping the followed tab, scroll to the top.
          followedScrollController.animateTo(
            0.0,
            duration: duration,
            curve: Curves.easeOut,
          );
        } else if (index == 1 &&
            topSectionScrollControllers[topSectionCurrentIndex].hasClients) {
          // If on the top section, scroll to the top of the tab based on the current top tab.
          topSectionScrollControllers[topSectionCurrentIndex].animateTo(
            0.0,
            duration: duration,
            curve: Curves.easeOut,
          );
        } else if (searchScrollController.hasClients) {
          // If on the search tab and tapping the search tab, scroll to the top.
          searchScrollController.animateTo(
            0.0,
            duration: duration,
            curve: Curves.easeOut,
          );
        }
      } else {
        if (index == 0 &&
            topSectionScrollControllers[topSectionCurrentIndex].hasClients) {
          // If on the top section, scroll to the top of the tab based on the current top tab.
          topSectionScrollControllers[topSectionCurrentIndex].animateTo(
            0.0,
            duration: duration,
            curve: Curves.easeOut,
          );
        } else if (searchScrollController.hasClients) {
          // If on the search tab and tapping the search tab, scroll to the top.
          searchScrollController.animateTo(
            0.0,
            duration: duration,
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  void dispose() {
    _disposeReaction();

    followedScrollController.dispose();

    for (final controller in topSectionScrollControllers) {
      controller.dispose();
    }
  }
}

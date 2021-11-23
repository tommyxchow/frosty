import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_store.g.dart';

class SettingsStore = _SettingsStoreBase with _$SettingsStore;

abstract class _SettingsStoreBase with Store {
  @observable
  bool videoEnabled = true;

  @observable
  double messageLimit = 200;

  Future<void> init() async {
    // Retrieve the instance that will allow us to store and persist settings.
    final prefs = await SharedPreferences.getInstance();

    // Initialize settings from stored preferences if any.
    videoEnabled = prefs.getBool('video_enabled') ?? videoEnabled;
    messageLimit = prefs.getDouble('message_limit') ?? messageLimit;

    // Set up autorun to store setting anytime they're changed.
    // The ReactionDisposer will not be needed since settings will always exist.
    autorun((_) {
      debugPrint('settings changed');
      prefs.setBool('video_enabled', videoEnabled);
      prefs.setDouble('message_limit', messageLimit);
    });
  }
}

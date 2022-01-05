import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'settings_store.g.dart';

@JsonSerializable()
class SettingsStore extends _SettingsStoreBase with _$SettingsStore {
  SettingsStore();

  factory SettingsStore.fromJson(Map<String, dynamic> json) => _$SettingsStoreFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsStoreToJson(this);
}

abstract class _SettingsStoreBase with Store {
  //General Settings
  @observable
  var useOledTheme = false;

  // Video Settings
  @observable
  var showVideo = true;

  @observable
  var showOverlay = true;

  @observable
  var showThumbnailUptime = true;

  // Chat Settings
  @observable
  var hideBannedMessages = false;

  @observable
  var showZeroWidth = false;

  @observable
  var showTimestamps = false;

  @observable
  var useTwelveHourTimestamps = false;

  // Global configs
  @observable
  var fullScreen = false;

  @observable
  var expandInfo = false;

  _SettingsStoreBase() {
    // A MobX reaction that will toggle immersive mode whenever the user enters and exits fullscreen mode.
    reaction(
      (_) => fullScreen,
      (bool isFullscreen) => isFullscreen == true
          ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)
          : SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.manual,
              overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
            ),
    );
  }
}

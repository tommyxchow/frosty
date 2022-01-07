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
  @JsonKey(defaultValue: false)
  @observable
  var useOledTheme = false;

  @JsonKey(defaultValue: true)
  @observable
  var showThumbnailUptime = true;

  // Video Settings
  @JsonKey(defaultValue: true)
  @observable
  var showVideo = true;

  @JsonKey(defaultValue: true)
  @observable
  var showOverlay = true;

  @JsonKey(defaultValue: false)
  @observable
  var pictureInPicture = false;

  // Chat Settings
  @JsonKey(defaultValue: false)
  @observable
  var showDeletedMessages = false;

  @JsonKey(defaultValue: false)
  @observable
  var showZeroWidth = false;

  @JsonKey(defaultValue: false)
  @observable
  var showTimestamps = false;

  @JsonKey(defaultValue: false)
  @observable
  var useTwelveHourTimestamps = false;

  @JsonKey(defaultValue: true)
  @observable
  var useReadableColors = true;

  @JsonKey(defaultValue: 1.0)
  @observable
  var fontScale = 1.0;

  // Global configs
  @JsonKey(defaultValue: false)
  @observable
  var fullScreen = false;

  @JsonKey(defaultValue: true)
  @observable
  var expandInfo = true;

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

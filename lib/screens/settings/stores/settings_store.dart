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
  @JsonKey(defaultValue: ThemeType.system, unknownEnumValue: ThemeType.system)
  @observable
  var themeType = ThemeType.system;

  @JsonKey(defaultValue: false)
  @observable
  var showThumbnailUptime = false;

  // Video Settings
  @JsonKey(defaultValue: true)
  @observable
  var showVideo = true;

  @JsonKey(defaultValue: true)
  @observable
  var showOverlay = true;

  @JsonKey(defaultValue: false)
  @observable
  var toggleableOverlay = false;

  @JsonKey(defaultValue: false)
  @observable
  var pictureInPicture = false;

  // Chat Settings
  @JsonKey(defaultValue: true)
  @observable
  var showBottomBar = true;

  @JsonKey(defaultValue: false)
  @observable
  var showDeletedMessages = false;

  @JsonKey(defaultValue: false)
  @observable
  var showZeroWidth = false;

  @JsonKey(defaultValue: false)
  @observable
  var showChatMessageDividers = false;

  @JsonKey(defaultValue: TimestampType.disabled, unknownEnumValue: TimestampType.disabled)
  @observable
  var timestampType = TimestampType.disabled;

  @JsonKey(defaultValue: true)
  @observable
  var useReadableColors = true;

  @JsonKey(defaultValue: 1.0)
  @observable
  var messageScale = 1.0;

  @JsonKey(defaultValue: 14.0)
  @observable
  var fontSize = 14.0;

  @JsonKey(defaultValue: 10.0)
  @observable
  var messageSpacing = 10.0;

  @JsonKey(defaultValue: 1.0)
  @observable
  var badgeScale = 1.0;

  @JsonKey(defaultValue: 1.0)
  @observable
  var emoteScale = 1.0;

  // Other settings
  @JsonKey(defaultValue: true)
  @observable
  var sendCrashLogs = true;

  // Global configs
  @JsonKey(defaultValue: false)
  @observable
  var fullScreen = false;

  @JsonKey(defaultValue: true)
  @observable
  var expandInfo = true;
}

enum ThemeType {
  system,
  light,
  dark,
  black,
}

enum TimestampType {
  disabled,
  twelve,
  twentyFour,
}

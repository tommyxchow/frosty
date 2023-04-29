import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

// Twitch (default) user
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class UserTwitch {
  final String id;
  final String login;
  final String displayName;
  final String profileImageUrl;

  const UserTwitch(
    this.id,
    this.login,
    this.displayName,
    this.profileImageUrl,
  );

  factory UserTwitch.fromJson(Map<String, dynamic> json) =>
      _$UserTwitchFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class UserBlockedTwitch {
  final String userId;
  final String userLogin;
  final String displayName;

  const UserBlockedTwitch(
    this.userId,
    this.userLogin,
    this.displayName,
  );

  factory UserBlockedTwitch.fromJson(Map<String, dynamic> json) =>
      _$UserBlockedTwitchFromJson(json);
}

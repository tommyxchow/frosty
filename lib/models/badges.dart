import 'package:json_annotation/json_annotation.dart';

part 'badges.g.dart';

// Twitch Badges
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class BadgeInfoTwitch {
  @JsonKey(name: 'image_url_1x')
  final String imageUrl1x;
  @JsonKey(name: 'image_url_2x')
  final String imageUrl2x;
  @JsonKey(name: 'image_url_4x')
  final String imageUrl4x;

  final String description;
  final String title;
  final String clickAction;
  final String clickUrl;

  const BadgeInfoTwitch(
    this.imageUrl1x,
    this.imageUrl2x,
    this.imageUrl4x,
    this.description,
    this.title,
    this.clickAction,
    this.clickUrl,
  );

  factory BadgeInfoTwitch.fromJson(Map<String, dynamic> json) => _$BadgeInfoTwitchFromJson(json);
}

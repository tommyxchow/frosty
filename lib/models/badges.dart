import 'package:json_annotation/json_annotation.dart';

part 'badges.g.dart';

// Twitch Badges
@JsonSerializable(createToJson: false)
class BadgeImagesTwitch {
  final String id;
  @JsonKey(name: 'image_url_1x')
  final String imageUrl1x;
  @JsonKey(name: 'image_url_2x')
  final String imageUrl2x;
  @JsonKey(name: 'image_url_4x')
  final String imageUrl4x;

  const BadgeImagesTwitch(this.id, this.imageUrl1x, this.imageUrl2x, this.imageUrl4x);

  factory BadgeImagesTwitch.fromJson(Map<String, dynamic> json) => _$BadgeImagesTwitchFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class BadgesTwitch {
  final String setId;
  final List<BadgeImagesTwitch> versions;

  const BadgesTwitch(this.setId, this.versions);

  factory BadgesTwitch.fromJson(Map<String, dynamic> json) => _$BadgesTwitchFromJson(json);
}

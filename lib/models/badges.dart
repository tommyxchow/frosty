import 'package:json_annotation/json_annotation.dart';

part 'badges.g.dart';

// Twitch Badges
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class BadgeImagesTwitch {
  final String id;
  final String imageUrl1x;
  final String imageUrl2x;
  final String imageUrl4x;

  const BadgeImagesTwitch(this.id, this.imageUrl1x, this.imageUrl2x, this.imageUrl4x);

  factory BadgeImagesTwitch.fromJson(Map<String, dynamic> json) => _$BadgeImagesTwitchFromJson(json);
}

@JsonSerializable(createToJson: false)
class BadgesTwitch {
  final String setId;
  final List<BadgeImagesTwitch> versions;

  const BadgesTwitch(this.setId, this.versions);

  factory BadgesTwitch.fromJson(Map<String, dynamic> json) => _$BadgesTwitchFromJson(json);
}

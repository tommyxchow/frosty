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

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class BadgeInfoFFZ {
  final int id;
  final String name;
  final String title;
  final int slot;
  final String? replaces;
  final String color;
  final String image;
  final BadgeUrlsFFZ urls;

  const BadgeInfoFFZ(
    this.id,
    this.name,
    this.title,
    this.slot,
    this.replaces,
    this.color,
    this.image,
    this.urls,
  );

  factory BadgeInfoFFZ.fromJson(Map<String, dynamic> json) => _$BadgeInfoFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class BadgeUrlsFFZ {
  @JsonKey(name: '1')
  final String url1x;
  @JsonKey(name: '2')
  final String url2x;
  @JsonKey(name: '4')
  final String url4x;

  const BadgeUrlsFFZ(
    this.url1x,
    this.url2x,
    this.url4x,
  );

  factory BadgeUrlsFFZ.fromJson(Map<String, dynamic> json) => _$BadgeUrlsFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class BadgeInfo7TV {
  final String id;
  final String name;
  final String tooltip;
  final List<List<String>> urls;
  final List<String> users;

  BadgeInfo7TV(
    this.id,
    this.name,
    this.tooltip,
    this.urls,
    this.users,
  );

  factory BadgeInfo7TV.fromJson(Map<String, dynamic> json) => _$BadgeInfo7TVFromJson(json);
}

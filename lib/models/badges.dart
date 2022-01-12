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

@JsonSerializable(createToJson: false)
class BadgeInfoBTTV {
  final String id;
  final String name;
  final String displayName;
  final String providerId;
  final BadgeDetailsBTTV badge;

  BadgeInfoBTTV(
    this.id,
    this.name,
    this.displayName,
    this.providerId,
    this.badge,
  );

  factory BadgeInfoBTTV.fromJson(Map<String, dynamic> json) => _$BadgeInfoBTTVFromJson(json);
}

@JsonSerializable(createToJson: false)
class BadgeDetailsBTTV {
  final String description;
  final String svg;

  BadgeDetailsBTTV(
    this.description,
    this.svg,
  );

  factory BadgeDetailsBTTV.fromJson(Map<String, dynamic> json) => _$BadgeDetailsBTTVFromJson(json);
}

class Badge {
  final String name;
  final String url;
  final BadgeType type;
  final String? color;

  const Badge({
    required this.name,
    required this.url,
    this.color,
    required this.type,
  });

  factory Badge.fromTwitch(BadgeInfoTwitch badge) => Badge(
        name: badge.title,
        url: badge.imageUrl4x,
        type: BadgeType.twitch,
      );

  factory Badge.fromBTTV(BadgeInfoBTTV badge) => Badge(
        name: badge.badge.description,
        url: badge.badge.svg,
        type: BadgeType.bttv,
      );

  factory Badge.fromFFZ(BadgeInfoFFZ badge) => Badge(
        name: badge.title,
        url: badge.urls.url4x,
        color: badge.color,
        type: BadgeType.ffz,
      );

  factory Badge.from7TV(BadgeInfo7TV badge) => Badge(
        name: badge.tooltip,
        url: badge.urls[2][1],
        type: BadgeType.sevenTv,
      );
}

enum BadgeType {
  twitch,
  bttv,
  ffz,
  sevenTv,
}

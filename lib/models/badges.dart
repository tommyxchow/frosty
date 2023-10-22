import 'package:json_annotation/json_annotation.dart';

part 'badges.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class BadgeInfoTwitch {
  @JsonKey(name: 'image_url_1x')
  final String imageUrl1x;
  @JsonKey(name: 'image_url_2x')
  final String imageUrl2x;
  @JsonKey(name: 'image_url_4x')
  final String imageUrl4x;

  final String id;
  final String title;
  final String description;

  const BadgeInfoTwitch(
    this.imageUrl1x,
    this.imageUrl2x,
    this.imageUrl4x,
    this.id,
    this.title,
    this.description,
  );

  factory BadgeInfoTwitch.fromJson(Map<String, dynamic> json) =>
      _$BadgeInfoTwitchFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class BadgeInfoFFZ {
  final int id;
  final String title;
  final String color;
  final BadgeUrlsFFZ urls;

  const BadgeInfoFFZ(
    this.id,
    this.title,
    this.color,
    this.urls,
  );

  factory BadgeInfoFFZ.fromJson(Map<String, dynamic> json) =>
      _$BadgeInfoFFZFromJson(json);
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

  factory BadgeUrlsFFZ.fromJson(Map<String, dynamic> json) =>
      _$BadgeUrlsFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class BadgeInfo7TV {
  final String tooltip;
  final List<List<String>> urls;
  final List<String> users;

  BadgeInfo7TV(
    this.tooltip,
    this.urls,
    this.users,
  );

  factory BadgeInfo7TV.fromJson(Map<String, dynamic> json) =>
      _$BadgeInfo7TVFromJson(json);
}

@JsonSerializable(createToJson: false)
class BadgeInfoBTTV {
  final String providerId;
  final BadgeDetailsBTTV badge;

  BadgeInfoBTTV(
    this.providerId,
    this.badge,
  );

  factory BadgeInfoBTTV.fromJson(Map<String, dynamic> json) =>
      _$BadgeInfoBTTVFromJson(json);
}

@JsonSerializable(createToJson: false)
class BadgeDetailsBTTV {
  final String description;
  final String svg;

  BadgeDetailsBTTV(
    this.description,
    this.svg,
  );

  factory BadgeDetailsBTTV.fromJson(Map<String, dynamic> json) =>
      _$BadgeDetailsBTTVFromJson(json);
}

class ChatBadge {
  final String name;
  final String url;
  final BadgeType type;
  final String? color;

  const ChatBadge({
    required this.name,
    required this.url,
    this.color,
    required this.type,
  });

  factory ChatBadge.fromTwitch(BadgeInfoTwitch badge) => ChatBadge(
        name: badge.title,
        url: badge.imageUrl4x,
        type: BadgeType.twitch,
      );

  factory ChatBadge.fromBTTV(BadgeInfoBTTV badge) => ChatBadge(
        name: badge.badge.description,
        url: badge.badge.svg,
        type: BadgeType.bttv,
      );

  factory ChatBadge.fromFFZ(BadgeInfoFFZ badge) => ChatBadge(
        name: badge.title,
        url: badge.urls.url4x,
        color: badge.color,
        type: BadgeType.ffz,
      );

  factory ChatBadge.from7TV(BadgeInfo7TV badge) => ChatBadge(
        name: badge.tooltip,
        url: badge.urls[2][1],
        type: BadgeType.sevenTV,
      );
}

enum BadgeType {
  twitch,
  bttv,
  ffz,
  sevenTV;

  @override
  String toString() {
    switch (this) {
      case BadgeType.twitch:
        return 'Twitch badge';
      case BadgeType.bttv:
        return 'BetterTTV badge';
      case BadgeType.ffz:
        return 'FrankerFaceZ badge';
      case BadgeType.sevenTV:
        return '7TV badge';
    }
  }
}

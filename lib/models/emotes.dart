import 'package:frosty/constants/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'emotes.g.dart';

// * Twitch Emotes *
@JsonSerializable(createToJson: false)
class ImagesTwitch {
  @JsonKey(name: 'url_1x')
  final String url1x;
  @JsonKey(name: 'url_2x')
  final String url2x;
  @JsonKey(name: 'url_4x')
  final String url4x;

  const ImagesTwitch(
    this.url1x,
    this.url2x,
    this.url4x,
  );

  factory ImagesTwitch.fromJson(Map<String, dynamic> json) => _$ImagesTwitchFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class EmoteTwitch {
  final String id;
  final String name;
  final ImagesTwitch images;
  final String? tier;
  final String? emoteType;
  final String? emoteSetId;
  final String? ownerId;
  final List<String> format;
  final List<String> scale;
  final List<String> themeMode;

  const EmoteTwitch(
    this.id,
    this.name,
    this.images,
    this.tier,
    this.emoteType,
    this.emoteSetId,
    this.ownerId,
    this.format,
    this.scale,
    this.themeMode,
  );

  factory EmoteTwitch.fromJson(Map<String, dynamic> json) => _$EmoteTwitchFromJson(json);
}

// * BTTV Emotes *
@JsonSerializable(createToJson: false)
class EmoteBTTV {
  final String id;
  final String code;
  final String imageType;
  final String? userId;
  final UserBTTV? user;

  const EmoteBTTV(
    this.id,
    this.code,
    this.imageType,
    this.userId,
    this.user,
  );

  factory EmoteBTTV.fromJson(Map<String, dynamic> json) => _$EmoteBTTVFromJson(json);
}

@JsonSerializable(createToJson: false)
class UserBTTV {
  final String id;
  final String name;
  final String displayName;
  final String providerId;

  const UserBTTV(
    this.id,
    this.name,
    this.displayName,
    this.providerId,
  );

  factory UserBTTV.fromJson(Map<String, dynamic> json) => _$UserBTTVFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteBTTVChannel {
  final String id;
  final List<String> bots;
  final List<EmoteBTTV> channelEmotes;
  final List<EmoteBTTV> sharedEmotes;

  const EmoteBTTVChannel(
    this.id,
    this.bots,
    this.channelEmotes,
    this.sharedEmotes,
  );

  factory EmoteBTTVChannel.fromJson(Map<String, dynamic> json) => _$EmoteBTTVChannelFromJson(json);
}

// * FFZ Emotes *
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class RoomFFZ {
  final int set;
  final String? moderatorBadge;
  final ImagesFFZ? vipBadge;
  final ImagesFFZ? modUrls;
  // final Map<String, List<String>> userBadges;
  // final Map<String, List<int>> userBadgesIds;

  const RoomFFZ(
    this.set,
    this.moderatorBadge,
    this.vipBadge,
    this.modUrls,
  );

  factory RoomFFZ.fromJson(Map<String, dynamic> json) => _$RoomFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class ImagesFFZ {
  @JsonKey(name: '1')
  final String url1x;
  @JsonKey(name: '2')
  final String? url2x;
  @JsonKey(name: '4')
  final String? url4x;

  const ImagesFFZ(
    this.url1x,
    this.url2x,
    this.url4x,
  );

  factory ImagesFFZ.fromJson(Map<String, dynamic> json) => _$ImagesFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteFFZ {
  final int id;
  final String name;
  final int height;
  final int width;
  final OwnerFFZ owner;
  final ImagesFFZ urls;

  const EmoteFFZ(
    this.id,
    this.name,
    this.height,
    this.width,
    this.owner,
    this.urls,
  );

  factory EmoteFFZ.fromJson(Map<String, dynamic> json) => _$EmoteFFZFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class OwnerFFZ {
  @JsonKey(name: '_id')
  final int id;
  final String name;
  final String displayName;

  const OwnerFFZ(
    this.id,
    this.name,
    this.displayName,
  );

  factory OwnerFFZ.fromJson(Map<String, dynamic> json) => _$OwnerFFZFromJson(json);
}

// * 7TV Emotes *
@JsonSerializable(createToJson: false)
class Role7TV {
  final String id;
  final String name;
  final int position;
  final int color;
  final int allowed;
  final int denied;
  @JsonKey(name: 'default')
  final bool? defaults;

  const Role7TV(
    this.id,
    this.name,
    this.position,
    this.color,
    this.allowed,
    this.denied,
    this.defaults,
  );

  factory Role7TV.fromJson(Map<String, dynamic> json) => _$Role7TVFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Owner7TV {
  final String id;
  final String twitchId;
  final String login;
  final String displayName;
  final Role7TV role;

  const Owner7TV(
    this.id,
    this.twitchId,
    this.login,
    this.displayName,
    this.role,
  );

  factory Owner7TV.fromJson(Map<String, dynamic> json) => _$Owner7TVFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Emote7TV {
  final String id;
  final String name;
  final Owner7TV? owner;
  final int visibility;
  final List<String> visibilitySimple;
  final String mime;
  final int status;
  final List<String> tags;
  final List<int> width;
  final List<int> height;
  final List<List<String>> urls;

  const Emote7TV(
    this.id,
    this.name,
    this.owner,
    this.visibility,
    this.visibilitySimple,
    this.mime,
    this.status,
    this.tags,
    this.width,
    this.height,
    this.urls,
  );

  factory Emote7TV.fromJson(Map<String, dynamic> json) => _$Emote7TVFromJson(json);
}

/// The common emote class.
@JsonSerializable()
class Emote {
  final String name;
  final int? width;
  final int? height;
  final bool zeroWidth;
  final String url;
  final EmoteType type;
  final String? ownerId;

  const Emote({
    required this.name,
    this.width,
    this.height,
    required this.zeroWidth,
    required this.url,
    required this.type,
    this.ownerId,
  });

  factory Emote.fromTwitch(EmoteTwitch emote, EmoteType type) => Emote(
        name: emote.name,
        zeroWidth: false,
        url: 'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0',
        type: type,
        ownerId: emote.ownerId,
      );

  factory Emote.fromBTTV(EmoteBTTV emote, EmoteType type) => Emote(
        name: emote.code,
        zeroWidth: zeroWidthEmotes.contains(emote.code),
        url: 'https://cdn.betterttv.net/emote/${emote.id}/3x',
        type: type,
      );

  factory Emote.fromFFZ(EmoteFFZ emote, EmoteType type) => Emote(
        name: emote.name,
        zeroWidth: false,
        width: emote.width,
        height: emote.height,
        url: 'https:${emote.urls.url4x ?? emote.urls.url2x ?? emote.urls.url1x}',
        type: type,
      );

  factory Emote.from7TV(Emote7TV emote, EmoteType type) => Emote(
        name: emote.name,
        width: emote.width.first,
        height: emote.height.first,
        zeroWidth: emote.visibilitySimple.contains('ZERO_WIDTH'),
        url: emote.urls[3][1],
        type: type,
      );

  factory Emote.fromJson(Map<String, dynamic> json) => _$EmoteFromJson(json);
  Map<String, dynamic> toJson() => _$EmoteToJson(this);
}

const emoteType = [
  'Twitch (Bits Tier)',
  'Twitch (Follower)',
  'Twitch (Subscriber)',
  'Twitch (Global)',
  'Twitch (Unlocked)',
  'Twitch (Channel)',
  'FFZ (Global)',
  'FFZ (Channel)',
  'BTTV (Global)',
  'BTTV (Channel)',
  'BTTV (Shared)',
  '7TV (Global)',
  '7TV (Channel)',
];

enum EmoteType {
  twitchBits,
  twitchFollower,
  twitchSub,
  twitchGlobal,
  twitchUnlocked,
  twitchChannel,
  ffzGlobal,
  ffzChannel,
  bttvGlobal,
  bttvChannel,
  bttvShared,
  sevenTVGlobal,
  sevenTVChannel,
}

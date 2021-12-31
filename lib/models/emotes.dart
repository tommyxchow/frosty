import 'package:frosty/constants.dart';
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
@JsonSerializable(createToJson: false)
class UserFFZ {
  final int id;
  final String name;
  final String displayName;

  const UserFFZ(
    this.id,
    this.name,
    this.displayName,
  );

  factory UserFFZ.fromJson(Map<String, dynamic> json) => _$UserFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class ImagesFFZ {
  @JsonKey(name: '1x')
  final String url1x;
  @JsonKey(name: '2x')
  final String? url2x;
  @JsonKey(name: '4x')
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
  final UserFFZ user;
  final String code;
  final ImagesFFZ images;
  final String imageType;

  const EmoteFFZ(
    this.id,
    this.user,
    this.code,
    this.images,
    this.imageType,
  );

  factory EmoteFFZ.fromJson(Map<String, dynamic> json) => _$EmoteFFZFromJson(json);
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
class Emote {
  final String id;
  final String name;
  final int? width;
  final int? height;
  final bool zeroWidth;
  final String url;
  final EmoteType type;

  const Emote({
    required this.id,
    required this.name,
    this.width,
    this.height,
    required this.zeroWidth,
    required this.url,
    required this.type,
  });

  factory Emote.fromTwitch(EmoteTwitch emote, EmoteType type) => Emote(
        id: emote.id,
        name: emote.name,
        zeroWidth: false,
        url: 'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0',
        type: type,
      );

  factory Emote.fromBTTV(EmoteBTTV emote, EmoteType type) => Emote(
        id: emote.id,
        name: emote.code,
        zeroWidth: zeroWidthEmotes.contains(emote.code),
        url: 'https://cdn.betterttv.net/emote/${emote.id}/3x',
        type: type,
      );

  factory Emote.fromFFZ(EmoteFFZ emote, EmoteType type) => Emote(
        id: emote.id.toString(),
        name: emote.code,
        zeroWidth: false,
        url: emote.images.url4x ?? emote.images.url2x ?? emote.images.url1x,
        type: type,
      );

  factory Emote.from7TV(Emote7TV emote, EmoteType type) => Emote(
        id: emote.id,
        name: emote.name,
        width: emote.width.first,
        height: emote.height.first,
        zeroWidth: emote.visibilitySimple.isNotEmpty ? emote.visibilitySimple.first == "ZERO_WIDTH" : false,
        url: emote.urls[3][1],
        type: type,
      );
}

enum EmoteType {
  twitchSub,
  twitchGlobal,
  twitchUnlocked,
  twitchChannel,
  ffzGlobal,
  ffzChannel,
  bttvGlobal,
  bttvChannel,
  bttvShared,
  sevenTvGlobal,
  sevenTvChannel,
}

// Twitch Emotes
import 'package:json_annotation/json_annotation.dart';

part 'emotes.g.dart';

// Twitch Emotes
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ImagesTwitch {
  final String url1x;
  final String url2x;
  final String url4x;

  ImagesTwitch(this.url1x, this.url2x, this.url4x);

  factory ImagesTwitch.fromJson(Map<String, dynamic> json) => _$ImagesTwitchFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteTwitch {
  final String id;
  final String name;
  final ImagesTwitch images;
  final String? tier;
  final String? emoteType;
  final String? emoteSetId;

  EmoteTwitch(this.id, this.name, this.images, this.tier, this.emoteType, this.emoteSetId);

  factory EmoteTwitch.fromJson(Map<String, dynamic> json) => _$EmoteTwitchFromJson(json);
}

// BTTV Emotes
@JsonSerializable(createToJson: false)
class EmoteBTTVGlobal {
  final String id;
  final String code;
  final String imageType;
  final String userId;

  EmoteBTTVGlobal(this.id, this.code, this.imageType, this.userId);

  factory EmoteBTTVGlobal.fromJson(Map<String, dynamic> json) => _$EmoteBTTVGlobalFromJson(json);
}

@JsonSerializable(createToJson: false)
class UserBTTV {
  final String id;
  final String name;
  final String displayName;
  final String providerId;

  UserBTTV(this.id, this.name, this.displayName, this.providerId);

  factory UserBTTV.fromJson(Map<String, dynamic> json) => _$UserBTTVFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteBTTVShared {
  final String id;
  final String code;
  final String imageType;
  final UserBTTV user;

  EmoteBTTVShared(this.id, this.code, this.imageType, this.user);

  factory EmoteBTTVShared.fromJson(Map<String, dynamic> json) => _$EmoteBTTVSharedFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteBTTVChannel {
  final String id;
  final List<String> bots;
  final List<EmoteBTTVGlobal> channelEmotes;
  final List<EmoteBTTVShared> sharedEmotes;

  EmoteBTTVChannel(this.id, this.bots, this.channelEmotes, this.sharedEmotes);

  factory EmoteBTTVChannel.fromJson(Map<String, dynamic> json) => _$EmoteBTTVChannelFromJson(json);
}

// FFZ Emotes
@JsonSerializable(createToJson: false)
class UserFFZ {
  final int id;
  final String name;
  final String displayName;

  UserFFZ(this.id, this.name, this.displayName);

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

  ImagesFFZ(this.url1x, this.url2x, this.url4x);

  factory ImagesFFZ.fromJson(Map<String, dynamic> json) => _$ImagesFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteFFZ {
  final int id;
  final UserFFZ user;
  final String code;
  final ImagesFFZ images;
  final String imageType;

  EmoteFFZ(this.id, this.user, this.code, this.images, this.imageType);

  factory EmoteFFZ.fromJson(Map<String, dynamic> json) => _$EmoteFFZFromJson(json);
}

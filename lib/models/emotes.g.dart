// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImagesTwitch _$ImagesTwitchFromJson(Map<String, dynamic> json) {
  return ImagesTwitch(
    json['url_1x'] as String,
    json['url_2x'] as String,
    json['url_4x'] as String,
  );
}

EmoteTwitch _$EmoteTwitchFromJson(Map<String, dynamic> json) {
  return EmoteTwitch(
    json['id'] as String,
    json['name'] as String,
    ImagesTwitch.fromJson(json['images'] as Map<String, dynamic>),
    json['tier'] as String?,
    json['emote_type'] as String?,
    json['emote_set_id'] as String?,
    (json['format'] as List<dynamic>).map((e) => e as String).toList(),
    (json['scale'] as List<dynamic>).map((e) => e as String).toList(),
    (json['theme_mode'] as List<dynamic>).map((e) => e as String).toList(),
  );
}

EmoteBTTVGlobal _$EmoteBTTVGlobalFromJson(Map<String, dynamic> json) {
  return EmoteBTTVGlobal(
    json['id'] as String,
    json['code'] as String,
    json['imageType'] as String,
    json['userId'] as String,
  );
}

UserBTTV _$UserBTTVFromJson(Map<String, dynamic> json) {
  return UserBTTV(
    json['id'] as String,
    json['name'] as String,
    json['displayName'] as String,
    json['providerId'] as String,
  );
}

EmoteBTTVShared _$EmoteBTTVSharedFromJson(Map<String, dynamic> json) {
  return EmoteBTTVShared(
    json['id'] as String,
    json['code'] as String,
    json['imageType'] as String,
    UserBTTV.fromJson(json['user'] as Map<String, dynamic>),
  );
}

EmoteBTTVChannel _$EmoteBTTVChannelFromJson(Map<String, dynamic> json) {
  return EmoteBTTVChannel(
    json['id'] as String,
    (json['bots'] as List<dynamic>).map((e) => e as String).toList(),
    (json['channelEmotes'] as List<dynamic>).map((e) => EmoteBTTVGlobal.fromJson(e as Map<String, dynamic>)).toList(),
    (json['sharedEmotes'] as List<dynamic>).map((e) => EmoteBTTVShared.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

UserFFZ _$UserFFZFromJson(Map<String, dynamic> json) {
  return UserFFZ(
    json['id'] as int,
    json['name'] as String,
    json['displayName'] as String,
  );
}

ImagesFFZ _$ImagesFFZFromJson(Map<String, dynamic> json) {
  return ImagesFFZ(
    json['1x'] as String,
    json['2x'] as String?,
    json['4x'] as String?,
  );
}

EmoteFFZ _$EmoteFFZFromJson(Map<String, dynamic> json) {
  return EmoteFFZ(
    json['id'] as int,
    UserFFZ.fromJson(json['user'] as Map<String, dynamic>),
    json['code'] as String,
    ImagesFFZ.fromJson(json['images'] as Map<String, dynamic>),
    json['imageType'] as String,
  );
}

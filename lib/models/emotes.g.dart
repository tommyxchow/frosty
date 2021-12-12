// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImagesTwitch _$ImagesTwitchFromJson(Map<String, dynamic> json) => ImagesTwitch(
      json['url_1x'] as String,
      json['url_2x'] as String,
      json['url_4x'] as String,
    );

EmoteTwitch _$EmoteTwitchFromJson(Map<String, dynamic> json) => EmoteTwitch(
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

EmoteBTTV _$EmoteBTTVFromJson(Map<String, dynamic> json) => EmoteBTTV(
      json['id'] as String,
      json['code'] as String,
      json['imageType'] as String,
      json['userId'] as String?,
      json['user'] == null
          ? null
          : UserBTTV.fromJson(json['user'] as Map<String, dynamic>),
    );

UserBTTV _$UserBTTVFromJson(Map<String, dynamic> json) => UserBTTV(
      json['id'] as String,
      json['name'] as String,
      json['displayName'] as String,
      json['providerId'] as String,
    );

EmoteBTTVChannel _$EmoteBTTVChannelFromJson(Map<String, dynamic> json) =>
    EmoteBTTVChannel(
      json['id'] as String,
      (json['bots'] as List<dynamic>).map((e) => e as String).toList(),
      (json['channelEmotes'] as List<dynamic>)
          .map((e) => EmoteBTTV.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['sharedEmotes'] as List<dynamic>)
          .map((e) => EmoteBTTV.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

UserFFZ _$UserFFZFromJson(Map<String, dynamic> json) => UserFFZ(
      json['id'] as int,
      json['name'] as String,
      json['displayName'] as String,
    );

ImagesFFZ _$ImagesFFZFromJson(Map<String, dynamic> json) => ImagesFFZ(
      json['1x'] as String,
      json['2x'] as String?,
      json['4x'] as String?,
    );

EmoteFFZ _$EmoteFFZFromJson(Map<String, dynamic> json) => EmoteFFZ(
      json['id'] as int,
      UserFFZ.fromJson(json['user'] as Map<String, dynamic>),
      json['code'] as String,
      ImagesFFZ.fromJson(json['images'] as Map<String, dynamic>),
      json['imageType'] as String,
    );

Role7TV _$Role7TVFromJson(Map<String, dynamic> json) => Role7TV(
      json['id'] as String,
      json['name'] as String,
      json['position'] as int,
      json['color'] as int,
      json['allowed'] as int,
      json['denied'] as int,
      json['default'] as bool?,
    );

Owner7TV _$Owner7TVFromJson(Map<String, dynamic> json) => Owner7TV(
      json['id'] as String,
      json['twitch_id'] as String,
      json['login'] as String,
      json['display_name'] as String,
      Role7TV.fromJson(json['role'] as Map<String, dynamic>),
    );

Emote7TV _$Emote7TVFromJson(Map<String, dynamic> json) => Emote7TV(
      json['id'] as String,
      json['name'] as String,
      json['owner'] == null
          ? null
          : Owner7TV.fromJson(json['owner'] as Map<String, dynamic>),
      json['visibility'] as int,
      (json['visibility_simple'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      json['mime'] as String,
      json['status'] as int,
      (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      (json['width'] as List<dynamic>).map((e) => e as int).toList(),
      (json['height'] as List<dynamic>).map((e) => e as int).toList(),
      (json['urls'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
    );

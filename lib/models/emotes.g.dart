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
      json['owner_id'] as String?,
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

RoomFFZ _$RoomFFZFromJson(Map<String, dynamic> json) => RoomFFZ(
      json['set'] as int,
      json['moderator_badge'] as String?,
      json['vip_badge'] == null
          ? null
          : ImagesFFZ.fromJson(json['vip_badge'] as Map<String, dynamic>),
      json['mod_urls'] == null
          ? null
          : ImagesFFZ.fromJson(json['mod_urls'] as Map<String, dynamic>),
    );

ImagesFFZ _$ImagesFFZFromJson(Map<String, dynamic> json) => ImagesFFZ(
      json['1'] as String,
      json['2'] as String?,
      json['4'] as String?,
    );

EmoteFFZ _$EmoteFFZFromJson(Map<String, dynamic> json) => EmoteFFZ(
      json['id'] as int,
      json['name'] as String,
      json['height'] as int,
      json['width'] as int,
      OwnerFFZ.fromJson(json['owner'] as Map<String, dynamic>),
      ImagesFFZ.fromJson(json['urls'] as Map<String, dynamic>),
    );

OwnerFFZ _$OwnerFFZFromJson(Map<String, dynamic> json) => OwnerFFZ(
      json['_id'] as int,
      json['name'] as String,
      json['display_name'] as String,
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

Emote _$EmoteFromJson(Map<String, dynamic> json) => Emote(
      name: json['name'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      zeroWidth: json['zeroWidth'] as bool,
      url: json['url'] as String,
      type: $enumDecode(_$EmoteTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$EmoteToJson(Emote instance) => <String, dynamic>{
      'name': instance.name,
      'width': instance.width,
      'height': instance.height,
      'zeroWidth': instance.zeroWidth,
      'url': instance.url,
      'type': _$EmoteTypeEnumMap[instance.type],
    };

const _$EmoteTypeEnumMap = {
  EmoteType.twitchBits: 'twitchBits',
  EmoteType.twitchFollower: 'twitchFollower',
  EmoteType.twitchSub: 'twitchSub',
  EmoteType.twitchGlobal: 'twitchGlobal',
  EmoteType.twitchUnlocked: 'twitchUnlocked',
  EmoteType.twitchChannel: 'twitchChannel',
  EmoteType.ffzGlobal: 'ffzGlobal',
  EmoteType.ffzChannel: 'ffzChannel',
  EmoteType.bttvGlobal: 'bttvGlobal',
  EmoteType.bttvChannel: 'bttvChannel',
  EmoteType.bttvShared: 'bttvShared',
  EmoteType.sevenTVGlobal: 'sevenTVGlobal',
  EmoteType.sevenTVChannel: 'sevenTVChannel',
};

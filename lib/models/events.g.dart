// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SevenTVEvent _$SevenTVEventFromJson(Map<String, dynamic> json) => SevenTVEvent(
      op: json['op'] as int,
      t: json['t'] as int?,
      d: SevenTVEventData.fromJson(json['d'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SevenTVEventToJson(SevenTVEvent instance) {
  final val = <String, dynamic>{
    'op': instance.op,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('t', instance.t);
  val['d'] = instance.d;
  return val;
}

SevenTVEventData _$SevenTVEventDataFromJson(Map<String, dynamic> json) =>
    SevenTVEventData(
      type: json['type'] as String?,
      condition: (json['condition'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      body: json['body'] == null
          ? null
          : SevenTVEventEmoteSetBody.fromJson(
              json['body'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SevenTVEventDataToJson(SevenTVEventData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'condition': instance.condition,
    };

SevenTVEventUpdatedEmote _$SevenTVEventUpdatedEmoteFromJson(
        Map<String, dynamic> json) =>
    SevenTVEventUpdatedEmote(
      value: json['value'] == null
          ? null
          : Emote7TV.fromJson(json['value'] as Map<String, dynamic>),
      oldValue: json['old_value'] == null
          ? null
          : Emote7TV.fromJson(json['old_value'] as Map<String, dynamic>),
    );

SevenTVEventEmoteSetBody _$SevenTVEventEmoteSetBodyFromJson(
        Map<String, dynamic> json) =>
    SevenTVEventEmoteSetBody(
      actor: Emote7TVUser.fromJson(json['actor'] as Map<String, dynamic>),
      pushed: (json['pushed'] as List<dynamic>?)
          ?.map((e) =>
              SevenTVEventUpdatedEmote.fromJson(e as Map<String, dynamic>))
          .toList(),
      pulled: (json['pulled'] as List<dynamic>?)
          ?.map((e) =>
              SevenTVEventUpdatedEmote.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

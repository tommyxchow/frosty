// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeImagesTwitch _$BadgeImagesTwitchFromJson(Map<String, dynamic> json) {
  return BadgeImagesTwitch(
    json['id'] as String,
    json['image_url_1x'] as String,
    json['image_url_2x'] as String,
    json['image_url_4x'] as String,
  );
}

BadgesTwitch _$BadgesTwitchFromJson(Map<String, dynamic> json) {
  return BadgesTwitch(
    json['set_id'] as String,
    (json['versions'] as List<dynamic>)
        .map((e) => BadgeImagesTwitch.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

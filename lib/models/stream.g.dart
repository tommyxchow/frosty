// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamTwitch _$StreamTwitchFromJson(Map<String, dynamic> json) => StreamTwitch(
      json['id'] as String,
      json['user_id'] as String,
      json['user_login'] as String,
      json['user_name'] as String,
      json['game_id'] as String,
      json['game_name'] as String,
      json['type'] as String,
      json['title'] as String,
      json['viewer_count'] as int,
      json['started_at'] as String,
      json['language'] as String,
      json['thumbnail_url'] as String,
      (json['tag_ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['is_mature'] as bool,
    );

StreamsTwitch _$StreamsTwitchFromJson(Map<String, dynamic> json) =>
    StreamsTwitch(
      (json['data'] as List<dynamic>)
          .map((e) => StreamTwitch.fromJson(e as Map<String, dynamic>))
          .toList(),
      Map<String, String>.from(json['pagination'] as Map),
    );

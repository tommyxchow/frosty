// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stream _$StreamFromJson(Map<String, dynamic> json) => Stream(
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

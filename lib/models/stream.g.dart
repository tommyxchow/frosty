// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamTwitch _$StreamTwitchFromJson(Map<String, dynamic> json) => StreamTwitch(
      json['user_id'] as String,
      json['user_login'] as String,
      json['user_name'] as String,
      json['game_id'] as String,
      json['game_name'] as String,
      json['title'] as String,
      (json['viewer_count'] as num).toInt(),
      json['started_at'] as String,
      json['thumbnail_url'] as String,
    );

StreamsTwitch _$StreamsTwitchFromJson(Map<String, dynamic> json) =>
    StreamsTwitch(
      (json['data'] as List<dynamic>)
          .map((e) => StreamTwitch.fromJson(e as Map<String, dynamic>))
          .toList(),
      Map<String, String>.from(json['pagination'] as Map),
    );

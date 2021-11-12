// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stream _$StreamFromJson(Map<String, dynamic> json) => Stream(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userLogin: json['user_login'] as String,
      userName: json['user_name'] as String,
      gameId: json['game_id'] as String,
      gameName: json['game_name'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      viewerCount: json['viewer_count'] as int,
      startedAt: json['started_at'] as String,
      language: json['language'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      tagIds:
          (json['tag_ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isMature: json['is_mature'] as bool,
    );

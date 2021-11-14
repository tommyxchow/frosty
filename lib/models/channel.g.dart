// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
      broadcasterId: json['broadcaster_id'] as String,
      broadcasterLogin: json['broadcaster_login'] as String,
      broadcasterName: json['broadcaster_name'] as String,
      broadcasterLanguage: json['broadcaster_language'] as String,
      gameId: json['game_id'] as String,
      gameName: json['game_name'] as String,
      title: json['title'] as String,
      delay: json['delay'] as int,
    );

ChannelQuery _$ChannelQueryFromJson(Map<String, dynamic> json) => ChannelQuery(
      broadcasterLanguage: json['broadcaster_language'] as String,
      broadcasterLogin: json['broadcaster_login'] as String,
      displayName: json['display_name'] as String,
      gameId: json['game_id'] as String,
      gameName: json['game_name'] as String,
      id: json['id'] as String,
      isLive: json['is_live'] as bool,
      tagIds:
          (json['tag_ids'] as List<dynamic>).map((e) => e as String).toList(),
      thumbnailUrl: json['thumbnail_url'] as String,
      title: json['title'] as String,
      startedAt: json['started_at'] as String,
    );

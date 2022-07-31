// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
      broadcasterId: json['broadcaster_id'] as String,
      broadcasterLogin: json['broadcaster_login'] as String,
      broadcasterName: json['broadcaster_name'] as String,
    );

ChannelQuery _$ChannelQueryFromJson(Map<String, dynamic> json) => ChannelQuery(
      broadcasterLogin: json['broadcaster_login'] as String,
      displayName: json['display_name'] as String,
      id: json['id'] as String,
      isLive: json['is_live'] as bool,
      startedAt: json['started_at'] as String,
    );

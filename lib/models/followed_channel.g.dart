// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followed_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowedChannel _$FollowedChannelFromJson(Map<String, dynamic> json) =>
    FollowedChannel(
      broadcasterId: json['broadcaster_id'] as String,
      broadcasterLogin: json['broadcaster_login'] as String,
      broadcasterName: json['broadcaster_name'] as String,
      followedAt: DateTime.parse(json['followed_at'] as String),
    );

FollowedChannels _$FollowedChannelsFromJson(Map<String, dynamic> json) =>
    FollowedChannels(
      data: (json['data'] as List<dynamic>)
          .map((e) => FollowedChannel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Map<String, String>.from(json['pagination'] as Map),
      total: (json['total'] as num).toInt(),
    );

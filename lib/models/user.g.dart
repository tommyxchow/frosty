// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTwitch _$UserTwitchFromJson(Map<String, dynamic> json) => UserTwitch(
      json['id'] as String,
      json['login'] as String,
      json['display_name'] as String,
      json['type'] as String,
      json['broadcaster_type'] as String,
      json['description'] as String,
      json['profile_image_url'] as String,
      json['offline_image_url'] as String,
      json['view_count'] as int,
      json['created_at'] as String,
    );

UserBlockedTwitch _$UserBlockedTwitchFromJson(Map<String, dynamic> json) =>
    UserBlockedTwitch(
      json['user_id'] as String,
      json['user_login'] as String,
      json['display_name'] as String,
    );

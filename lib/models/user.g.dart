// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTwitch _$UserTwitchFromJson(Map<String, dynamic> json) => UserTwitch(
      json['id'] as String,
      json['login'] as String,
      json['display_name'] as String,
      json['profile_image_url'] as String,
    );

UserBlockedTwitch _$UserBlockedTwitchFromJson(Map<String, dynamic> json) =>
    UserBlockedTwitch(
      json['user_id'] as String,
      json['user_login'] as String,
      json['display_name'] as String,
    );

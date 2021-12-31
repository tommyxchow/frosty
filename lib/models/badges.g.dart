// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badges.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BadgeInfoTwitch _$BadgeInfoTwitchFromJson(Map<String, dynamic> json) =>
    BadgeInfoTwitch(
      json['image_url_1x'] as String,
      json['image_url_2x'] as String,
      json['image_url_4x'] as String,
      json['description'] as String,
      json['title'] as String,
      json['click_action'] as String,
      json['click_url'] as String,
    );

BadgeInfoFFZ _$BadgeInfoFFZFromJson(Map<String, dynamic> json) => BadgeInfoFFZ(
      json['id'] as int,
      json['name'] as String,
      json['title'] as String,
      json['slot'] as int,
      json['replaces'] as String?,
      json['color'] as String,
      json['image'] as String,
      BadgeUrlsFFZ.fromJson(json['urls'] as Map<String, dynamic>),
    );

BadgeUrlsFFZ _$BadgeUrlsFFZFromJson(Map<String, dynamic> json) => BadgeUrlsFFZ(
      json['1'] as String,
      json['2'] as String,
      json['4'] as String,
    );

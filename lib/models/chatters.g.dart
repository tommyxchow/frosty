// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatUsers _$ChatUsersFromJson(Map<String, dynamic> json) => ChatUsers(
      (json['chatter_count'] as num).toInt(),
      Chatters.fromJson(json['chatters'] as Map<String, dynamic>),
    );

Chatters _$ChattersFromJson(Map<String, dynamic> json) => Chatters(
      (json['broadcaster'] as List<dynamic>).map((e) => e as String).toList(),
      (json['vips'] as List<dynamic>).map((e) => e as String).toList(),
      (json['moderators'] as List<dynamic>).map((e) => e as String).toList(),
      (json['staff'] as List<dynamic>).map((e) => e as String).toList(),
      (json['admins'] as List<dynamic>).map((e) => e as String).toList(),
      (json['global_mods'] as List<dynamic>).map((e) => e as String).toList(),
      (json['viewers'] as List<dynamic>).map((e) => e as String).toList(),
    );

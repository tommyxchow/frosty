// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_chat_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedChatSession _$SharedChatSessionFromJson(Map<String, dynamic> json) =>
    SharedChatSession(
      sessionId: json['session_id'] as String,
      hostBroadcasterId: json['host_broadcaster_id'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
      broadcasterId: json['broadcaster_id'] as String,
    );

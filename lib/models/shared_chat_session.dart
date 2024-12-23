import 'package:json_annotation/json_annotation.dart';

part 'shared_chat_session.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class SharedChatSession {
  final String sessionId;
  final String hostBroadcasterId;
  final List<Participant> participants;
  final String createdAt;
  final String updatedAt;

  SharedChatSession({
    required this.sessionId,
    required this.hostBroadcasterId,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SharedChatSession.fromJson(Map<String, dynamic> json) =>
      _$SharedChatSessionFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Participant {
  final String broadcasterId;

  Participant({required this.broadcasterId});

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
}

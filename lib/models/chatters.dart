import 'package:json_annotation/json_annotation.dart';

part 'chatters.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ChatUsers {
  final int chatterCount;
  final Chatters chatters;

  ChatUsers(
    this.chatterCount,
    this.chatters,
  );

  factory ChatUsers.fromJson(Map<String, dynamic> json) =>
      _$ChatUsersFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Chatters {
  final List<String> broadcaster;
  final List<String> vips;
  final List<String> moderators;
  final List<String> staff;
  final List<String> admins;
  final List<String> globalMods;
  final List<String> viewers;

  const Chatters(
    this.broadcaster,
    this.vips,
    this.moderators,
    this.staff,
    this.admins,
    this.globalMods,
    this.viewers,
  );

  factory Chatters.fromJson(Map<String, dynamic> json) =>
      _$ChattersFromJson(json);
}

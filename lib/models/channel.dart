import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

// Object for Twitch channels.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Channel {
  final String broadcasterId;
  final String broadcasterLogin;
  final String broadcasterName;
  final String broadcasterLanguage;
  final String gameId;
  final String gameName;
  final String title;
  final int delay;

  const Channel({
    required this.broadcasterId,
    required this.broadcasterLogin,
    required this.broadcasterName,
    required this.broadcasterLanguage,
    required this.gameId,
    required this.gameName,
    required this.title,
    required this.delay,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}

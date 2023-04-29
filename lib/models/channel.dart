import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

// Object for Twitch channel GET request.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Channel {
  final String broadcasterId;
  final String broadcasterLogin;
  final String broadcasterName;

  const Channel({
    required this.broadcasterId,
    required this.broadcasterLogin,
    required this.broadcasterName,
  });

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);
}

// Object for Twitch channel search query.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ChannelQuery {
  final String broadcasterLogin;
  final String displayName;
  final String id;
  final bool isLive;
  final String startedAt;

  const ChannelQuery({
    required this.broadcasterLogin,
    required this.displayName,
    required this.id,
    required this.isLive,
    required this.startedAt,
  });

  factory ChannelQuery.fromJson(Map<String, dynamic> json) =>
      _$ChannelQueryFromJson(json);
}

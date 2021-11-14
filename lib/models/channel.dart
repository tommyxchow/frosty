import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

// Object for Twitch channel GET request.
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

// Object for Twitch channel search query.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class ChannelQuery {
  final String broadcasterLanguage;
  final String broadcasterLogin;
  final String displayName;
  final String gameId;
  final String gameName;
  final String id;
  final bool isLive;
  final List<String> tagIds;
  final String thumbnailUrl;
  final String title;
  final String startedAt;

  const ChannelQuery({
    required this.broadcasterLanguage,
    required this.broadcasterLogin,
    required this.displayName,
    required this.gameId,
    required this.gameName,
    required this.id,
    required this.isLive,
    required this.tagIds,
    required this.thumbnailUrl,
    required this.title,
    required this.startedAt,
  });

  factory ChannelQuery.fromJson(Map<String, dynamic> json) => _$ChannelQueryFromJson(json);
}

import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

// ! Seems like when a channel just went live (< 2 min), tagIds are null. Possibly make it optional.

// Twitch Channels (Streams)
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Channel {
  final String id;
  final String userId;
  final String userLogin;
  final String userName;
  final String gameId;
  final String gameName;
  final String type;
  final String title;
  final int viewerCount;
  final String startedAt;
  final String language;
  final String thumbnailUrl;
  final List<String> tagIds;
  final bool isMature;

  const Channel({
    required this.id,
    required this.userId,
    required this.userLogin,
    required this.userName,
    required this.gameId,
    required this.gameName,
    required this.type,
    required this.title,
    required this.viewerCount,
    required this.startedAt,
    required this.language,
    required this.thumbnailUrl,
    required this.tagIds,
    required this.isMature,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}

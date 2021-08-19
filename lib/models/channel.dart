import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

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

  const Channel(this.id, this.userId, this.userLogin, this.userName, this.gameId, this.gameName, this.type, this.title, this.viewerCount, this.startedAt,
      this.language, this.thumbnailUrl, this.tagIds, this.isMature);

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}

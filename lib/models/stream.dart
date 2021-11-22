import 'package:json_annotation/json_annotation.dart';

part 'stream.g.dart';

// Object for live Twitch streams.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class StreamTwitch {
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
  final List<String>? tagIds;
  final bool isMature;

  const StreamTwitch(
    this.id,
    this.userId,
    this.userLogin,
    this.userName,
    this.gameId,
    this.gameName,
    this.type,
    this.title,
    this.viewerCount,
    this.startedAt,
    this.language,
    this.thumbnailUrl,
    this.tagIds,
    this.isMature,
  );

  factory StreamTwitch.fromJson(Map<String, dynamic> json) => _$StreamTwitchFromJson(json);
}

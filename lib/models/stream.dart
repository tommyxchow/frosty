import 'package:json_annotation/json_annotation.dart';

part 'stream.g.dart';

// Object for live Twitch streams.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class StreamTwitch {
  final String userId;
  final String userLogin;
  final String userName;
  final String gameId;
  final String gameName;
  final String title;
  final int viewerCount;
  final String startedAt;
  final String thumbnailUrl;

  const StreamTwitch(
    this.userId,
    this.userLogin,
    this.userName,
    this.gameId,
    this.gameName,
    this.title,
    this.viewerCount,
    this.startedAt,
    this.thumbnailUrl,
  );

  factory StreamTwitch.fromJson(Map<String, dynamic> json) =>
      _$StreamTwitchFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class StreamsTwitch {
  final List<StreamTwitch> data;
  final Map<String, String> pagination;

  const StreamsTwitch(
    this.data,
    this.pagination,
  );

  factory StreamsTwitch.fromJson(Map<String, dynamic> json) =>
      _$StreamsTwitchFromJson(json);
}

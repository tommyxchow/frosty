import 'package:json_annotation/json_annotation.dart';

part 'followed_channel.g.dart';

// Object for followed Twitch channels.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class FollowedChannel {
  final String broadcasterId;
  final String broadcasterLogin;
  final String broadcasterName;
  final DateTime followedAt;

  const FollowedChannel({
    required this.broadcasterId,
    required this.broadcasterLogin,
    required this.broadcasterName,
    required this.followedAt,
  });

  factory FollowedChannel.fromJson(Map<String, dynamic> json) =>
      _$FollowedChannelFromJson(json);
}

// Response object for followed channels API call.
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class FollowedChannels {
  final List<FollowedChannel> data;
  final Map<String, String> pagination;
  final int total;

  const FollowedChannels({
    required this.data,
    required this.pagination,
    required this.total,
  });

  factory FollowedChannels.fromJson(Map<String, dynamic> json) =>
      _$FollowedChannelsFromJson(json);
}

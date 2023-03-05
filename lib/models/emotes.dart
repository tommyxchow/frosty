import 'package:frosty/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'emotes.g.dart';

// * Twitch Emotes *
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class EmoteTwitch {
  final String id;
  final String name;
  final String? emoteType;
  final String? ownerId;

  const EmoteTwitch(
    this.id,
    this.name,
    this.emoteType,
    this.ownerId,
  );

  factory EmoteTwitch.fromJson(Map<String, dynamic> json) => _$EmoteTwitchFromJson(json);
}

// * BTTV Emotes *
@JsonSerializable(createToJson: false)
class EmoteBTTV {
  final String id;
  final String code;

  const EmoteBTTV(
    this.id,
    this.code,
  );

  factory EmoteBTTV.fromJson(Map<String, dynamic> json) => _$EmoteBTTVFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteBTTVChannel {
  final List<EmoteBTTV> channelEmotes;
  final List<EmoteBTTV> sharedEmotes;

  const EmoteBTTVChannel(
    this.channelEmotes,
    this.sharedEmotes,
  );

  factory EmoteBTTVChannel.fromJson(Map<String, dynamic> json) => _$EmoteBTTVChannelFromJson(json);
}

// * FFZ Emotes *
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class RoomFFZ {
  final int set;
  final ImagesFFZ? vipBadge;
  final ImagesFFZ? modUrls;

  const RoomFFZ(
    this.set,
    this.vipBadge,
    this.modUrls,
  );

  factory RoomFFZ.fromJson(Map<String, dynamic> json) => _$RoomFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class ImagesFFZ {
  @JsonKey(name: '1')
  final String url1x;
  @JsonKey(name: '2')
  final String? url2x;
  @JsonKey(name: '4')
  final String? url4x;

  const ImagesFFZ(
    this.url1x,
    this.url2x,
    this.url4x,
  );

  factory ImagesFFZ.fromJson(Map<String, dynamic> json) => _$ImagesFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteFFZ {
  final String name;
  final int height;
  final int width;
  final ImagesFFZ urls;

  const EmoteFFZ(
    this.name,
    this.height,
    this.width,
    this.urls,
  );

  factory EmoteFFZ.fromJson(Map<String, dynamic> json) => _$EmoteFFZFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Emote7TV {
  final String name;
  final List<String> visibilitySimple;
  final List<int> width;
  final List<int> height;
  final List<List<String>> urls;

  const Emote7TV(
    this.name,
    this.visibilitySimple,
    this.width,
    this.height,
    this.urls,
  );

  factory Emote7TV.fromJson(Map<String, dynamic> json) => _$Emote7TVFromJson(json);
}

/// The common emote class.
@JsonSerializable()
class Emote {
  final String name;
  final int? width;
  final int? height;
  final bool zeroWidth;
  final String url;
  final EmoteType type;
  final String? ownerId;

  const Emote({
    required this.name,
    this.width,
    this.height,
    required this.zeroWidth,
    required this.url,
    required this.type,
    this.ownerId,
  });

  factory Emote.fromTwitch(EmoteTwitch emote, EmoteType type) => Emote(
        name: emote.name,
        zeroWidth: false,
        url: 'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0',
        type: type,
        ownerId: emote.ownerId,
      );

  factory Emote.fromBTTV(EmoteBTTV emote, EmoteType type) => Emote(
        name: emote.code,
        zeroWidth: zeroWidthEmotes.contains(emote.code),
        url: 'https://cdn.betterttv.net/emote/${emote.id}/3x',
        type: type,
      );

  factory Emote.fromFFZ(EmoteFFZ emote, EmoteType type) => Emote(
        name: emote.name,
        zeroWidth: false,
        width: emote.width,
        height: emote.height,
        url: emote.urls.url4x ?? emote.urls.url2x ?? emote.urls.url1x,
        type: type,
      );

  factory Emote.from7TV(Emote7TV emote, EmoteType type) => Emote(
        name: emote.name,
        width: emote.width.first,
        height: emote.height.first,
        zeroWidth: emote.visibilitySimple.contains('ZERO_WIDTH'),
        url: emote.urls[3][1],
        type: type,
      );

  factory Emote.fromJson(Map<String, dynamic> json) => _$EmoteFromJson(json);
  Map<String, dynamic> toJson() => _$EmoteToJson(this);
}

const emoteType = [
  'Twitch (Bits Tier)',
  'Twitch (Follower)',
  'Twitch (Subscriber)',
  'Twitch (Global)',
  'Twitch (Unlocked)',
  'Twitch (Channel)',
  'FFZ (Global)',
  'FFZ (Channel)',
  'BTTV (Global)',
  'BTTV (Channel)',
  'BTTV (Shared)',
  '7TV (Global)',
  '7TV (Channel)',
];

enum EmoteType {
  twitchBits,
  twitchFollower,
  twitchSub,
  twitchGlobal,
  twitchUnlocked,
  twitchChannel,
  ffzGlobal,
  ffzChannel,
  bttvGlobal,
  bttvChannel,
  bttvShared,
  sevenTVGlobal,
  sevenTVChannel,
}

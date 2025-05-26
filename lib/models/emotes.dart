import 'package:collection/collection.dart';
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

  factory EmoteTwitch.fromJson(Map<String, dynamic> json) =>
      _$EmoteTwitchFromJson(json);
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

  factory EmoteBTTV.fromJson(Map<String, dynamic> json) =>
      _$EmoteBTTVFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteBTTVChannel {
  final List<EmoteBTTV> channelEmotes;
  final List<EmoteBTTV> sharedEmotes;

  const EmoteBTTVChannel(
    this.channelEmotes,
    this.sharedEmotes,
  );

  factory EmoteBTTVChannel.fromJson(Map<String, dynamic> json) =>
      _$EmoteBTTVChannelFromJson(json);
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

  factory RoomFFZ.fromJson(Map<String, dynamic> json) =>
      _$RoomFFZFromJson(json);
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

  factory ImagesFFZ.fromJson(Map<String, dynamic> json) =>
      _$ImagesFFZFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class OwnerFFZ {
  final String displayName;
  final String name;

  const OwnerFFZ({
    required this.displayName,
    required this.name,
  });

  factory OwnerFFZ.fromJson(Map<String, dynamic> json) =>
      _$OwnerFFZFromJson(json);
}

@JsonSerializable(createToJson: false)
class EmoteFFZ {
  final String name;
  final int height;
  final int width;
  final OwnerFFZ owner;
  final ImagesFFZ urls;
  final ImagesFFZ? animated;

  const EmoteFFZ(
    this.name,
    this.height,
    this.width,
    this.owner,
    this.urls,
    this.animated,
  );

  factory EmoteFFZ.fromJson(Map<String, dynamic> json) =>
      _$EmoteFFZFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Emote7TV {
  final String id;
  final String name;
  final Emote7TVData data;

  const Emote7TV(
    this.id,
    this.name,
    this.data,
  );

  factory Emote7TV.fromJson(Map<String, dynamic> json) =>
      _$Emote7TVFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Owner7TV {
  final String username;
  final String displayName;

  const Owner7TV({
    required this.username,
    required this.displayName,
  });

  factory Owner7TV.fromJson(Map<String, dynamic> json) =>
      _$Owner7TVFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Emote7TVData {
  final String id;
  final String name;
  final int flags;
  final Owner7TV? owner;
  final Emote7TVHost host;

  const Emote7TVData(
    this.id,
    this.name,
    this.flags,
    this.owner,
    this.host,
  );

  factory Emote7TVData.fromJson(Map<String, dynamic> json) =>
      _$Emote7TVDataFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Emote7TVHost {
  final String url;
  final List<Emote7TVFile> files;

  Emote7TVHost(
    this.url,
    this.files,
  );

  factory Emote7TVHost.fromJson(Map<String, dynamic> json) =>
      _$Emote7TVHostFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Emote7TVFile {
  final String name;
  final int width;
  final int height;
  final String format;

  Emote7TVFile(
    this.name,
    this.width,
    this.height,
    this.format,
  );

  factory Emote7TVFile.fromJson(Map<String, dynamic> json) =>
      _$Emote7TVFileFromJson(json);
}

/// The common emote class.
@JsonSerializable()
class Emote {
  final String name;
  final String? realName;
  final int? width;
  final int? height;
  final bool zeroWidth;
  final String url;
  final EmoteType type;
  final String? ownerDisplayName;
  final String? ownerUsername;
  final String? ownerId;

  const Emote({
    required this.name,
    this.realName,
    this.width,
    this.height,
    required this.zeroWidth,
    required this.url,
    required this.type,
    this.ownerDisplayName,
    this.ownerUsername,
    this.ownerId,
  });

  factory Emote.fromTwitch(EmoteTwitch emote, EmoteType type) => Emote(
        name: emote.name,
        zeroWidth: false,
        url:
            'https://static-cdn.jtvnw.net/emoticons/v2/${emote.id}/default/dark/3.0',
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
        url: emote.animated?.url4x ??
            emote.animated?.url2x ??
            emote.animated?.url1x ??
            emote.urls.url4x ??
            emote.urls.url2x ??
            emote.urls.url1x,
        type: type,
        ownerDisplayName: emote.owner.displayName,
        ownerUsername: emote.owner.name,
      );

  factory Emote.from7TV(Emote7TV emote, EmoteType type) {
    final emoteData = emote.data;

    final url = emoteData.host.url;

    // TODO: Remove if/when Flutter natively supports AVIF.
    final file = emoteData.host.files.lastWhereOrNull(
      (file) => file.format != 'AVIF',
    );

    // Check if the flag has 1 at the 8th bit.
    final isZeroWidth = (emoteData.flags & 256) == 256;

    return Emote(
      name: emote.name,
      realName: emote.name != emoteData.name ? emoteData.name : null,
      width: emoteData.host.files.firstOrNull?.width,
      height: emoteData.host.files.firstOrNull?.height,
      zeroWidth: isZeroWidth,
      url: file != null ? 'https:$url/${file.name}' : '',
      type: type,
      ownerDisplayName: emoteData.owner?.displayName,
      ownerUsername: emoteData.owner?.username,
    );
  }

  factory Emote.fromJson(Map<String, dynamic> json) => _$EmoteFromJson(json);
  Map<String, dynamic> toJson() => _$EmoteToJson(this);
}

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
  sevenTVChannel;

  @override
  String toString() {
    switch (this) {
      case EmoteType.twitchBits:
        return 'Twitch bits emote';
      case EmoteType.twitchFollower:
        return 'Twitch follower emote';
      case EmoteType.twitchSub:
        return 'Twitch sub emote';
      case EmoteType.twitchGlobal:
        return 'Twitch global emote';
      case EmoteType.twitchUnlocked:
        return 'Twitch unlocked emote';
      case EmoteType.twitchChannel:
        return 'Twitch channel emote';
      case EmoteType.ffzGlobal:
        return 'FrankerFaceZ global emote';
      case EmoteType.ffzChannel:
        return 'FrankerFaceZ channel emote';
      case EmoteType.bttvGlobal:
        return 'BetterTTV global emote';
      case EmoteType.bttvChannel:
        return 'BetterTTV channel emote';
      case EmoteType.bttvShared:
        return 'BetterTTV shared emote';
      case EmoteType.sevenTVGlobal:
        return '7TV global emote';
      case EmoteType.sevenTVChannel:
        return '7TV channel emote';
    }
  }
}

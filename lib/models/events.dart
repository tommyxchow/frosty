import 'package:frosty/models/emotes.dart';
import 'package:json_annotation/json_annotation.dart';

part 'events.g.dart';

@JsonSerializable()
class SevenTVEvent {
  final int op;
  @JsonKey(includeIfNull: false)
  final int? t;
  final SevenTVEventData d;

  const SevenTVEvent({
    required this.op,
    this.t,
    required this.d,
  });

  factory SevenTVEvent.fromJson(Map<String, dynamic> json) =>
      _$SevenTVEventFromJson(json);

  Map<String, dynamic> toJson() => _$SevenTVEventToJson(this);
}

@JsonSerializable()
class SevenTVEventData {
  final String? type;
  final Map<String, String>? condition;
  @JsonKey(includeToJson: false)
  final SevenTVEventEmoteSetBody? body;

  const SevenTVEventData({
    required this.type,
    this.condition,
    this.body,
  });

  factory SevenTVEventData.fromJson(Map<String, dynamic> json) =>
      _$SevenTVEventDataFromJson(json);

  Map<String, dynamic> toJson() => _$SevenTVEventDataToJson(this);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class SevenTVEventUpdatedEmote {
  final Emote7TV? value;
  final Emote7TV? oldValue;

  const SevenTVEventUpdatedEmote({
    this.value,
    this.oldValue,
  });

  factory SevenTVEventUpdatedEmote.fromJson(Map<String, dynamic> json) =>
      _$SevenTVEventUpdatedEmoteFromJson(json);
}

@JsonSerializable(createToJson: false)
class SevenTVEventEmoteSetBody {
  final Owner7TV actor;
  final List<SevenTVEventUpdatedEmote>? pushed;
  final List<SevenTVEventUpdatedEmote>? pulled;

  const SevenTVEventEmoteSetBody({
    required this.actor,
    this.pushed,
    this.pulled,
  });

  factory SevenTVEventEmoteSetBody.fromJson(Map<String, dynamic> json) =>
      _$SevenTVEventEmoteSetBodyFromJson(json);
}

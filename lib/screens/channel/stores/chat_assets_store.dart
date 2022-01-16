import 'package:frosty/api/bttv_api.dart';
import 'package:frosty/api/ffz_api.dart';
import 'package:frosty/api/seventv_api.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:mobx/mobx.dart';

part 'chat_assets_store.g.dart';

class ChatAssetsStore = _ChatAssetsStoreBase with _$ChatAssetsStore;

abstract class _ChatAssetsStoreBase with Store {
  final TwitchApi twitchApi;
  final BTTVApi bttvApi;
  final FFZApi ffzApi;
  final SevenTVApi sevenTvApi;

  /// Contains any custom FFZ mod and vip badges for the channel.
  RoomFFZ? ffzRoomInfo;

  @computed
  List<Emote> get bttvEmotes => _emoteToObject.values.where((emote) => isBTTV(emote)).toList();

  @computed
  List<Emote> get ffzEmotes => _emoteToObject.values.where((emote) => isFFZ(emote)).toList();

  @computed
  List<Emote> get sevenTvEmotes => _emoteToObject.values.where((emote) => is7TV(emote)).toList();

  /// The map of badges ids to their object representation.
  final twitchBadgesToObject = ObservableMap<String, Badge>();

  /// The map of emote words to their image or GIF URL. May be used by anyone in the chat.
  @readonly
  var _emoteToObject = <String, Emote>{};

  /// The emotes that are "owned" and may be used by the current user.
  @readonly
  var _userEmoteToObject = <String, Emote>{};

  /// The map of user IDs to their FFZ badges.
  @readonly
  var _userToFFZBadges = <String, List<Badge>>{};

  /// The map of user IDs to their 7TV badges.
  @readonly
  var _userTo7TVBadges = <String, List<Badge>>{};

  /// The map of user IDs to their BTTV badge.
  @readonly
  var _userToBTTVBadges = <String, Badge>{};

  /// The current index of the emote menu stack.
  @observable
  var emoteMenuIndex = 0;

  /// Whether or not the emote menu is visible.
  @observable
  var showEmoteMenu = false;

  bool isBTTV(Emote emote) {
    return emote.type == EmoteType.bttvChannel || emote.type == EmoteType.bttvGlobal || emote.type == EmoteType.bttvShared;
  }

  bool isFFZ(Emote emote) {
    return emote.type == EmoteType.ffzChannel || emote.type == EmoteType.ffzGlobal;
  }

  bool is7TV(Emote emote) {
    return emote.type == EmoteType.sevenTvChannel || emote.type == EmoteType.sevenTvGlobal;
  }

  _ChatAssetsStoreBase({
    required this.twitchApi,
    required this.bttvApi,
    required this.ffzApi,
    required this.sevenTvApi,
  });

  /// Fetches global and channel assets (badges and emotes) and stores them in [_emoteToUrl]
  @action
  Future<void> assetsFuture({
    required String channelName,
    required String channelId,
    required Map<String, String> headers,
    required Function onEmoteError,
    required Function onBadgeError,
  }) =>
      // Fetch the global and channel's assets (emotes & badges).
      // Async awaits are placed in a list so they are performed in parallel.
      Future.wait([
        emotesFuture(
          channelName: channelName,
          channelId: channelId,
          headers: headers,
          onError: onEmoteError,
        ),
        badgesFuture(
          channelId: channelId,
          headers: headers,
          onError: onBadgeError,
        ),
      ]);

  @action
  Future<void> emotesFuture({
    required String channelId,
    required String channelName,
    required Map<String, String> headers,
    required Function onError,
  }) =>
      // Parallel futures look ugly, but are worth the performance improvement.
      // Each future has it's own catchError so that the entire future is not ended on an error.
      // This will ensure that other futures complete even if one fails.
      Future.wait([
        ffzApi.getEmotesGlobal().catchError(onError),
        bttvApi.getEmotesGlobal().catchError(onError),
        bttvApi.getEmotesChannel(id: channelId).catchError(onError),
        twitchApi.getEmotesGlobal(headers: headers).catchError(onError),
        twitchApi.getEmotesChannel(id: channelId, headers: headers).catchError(onError),
        sevenTvApi.getEmotesGlobal().catchError(onError),
        sevenTvApi.getEmotesChannel(user: channelName).catchError(onError),
        ffzApi.getRoomInfo(name: channelName).then((ffzRoom) {
          ffzRoomInfo = ffzRoom.item1;
          return ffzRoom.item2;
        }).catchError(onError),
      ]).then((assets) => assets.expand((list) => list)).then((emotes) => _emoteToObject = {for (final emote in emotes) emote.name: emote});

  @action
  Future<void> badgesFuture({
    required String channelId,
    required Map<String, String> headers,
    required Function onError,
  }) =>
      Future.wait([
        twitchApi
            .getBadgesGlobal()
            .then((badges) => twitchBadgesToObject.addAll(badges))
            .then((_) => twitchApi.getBadgesChannel(id: channelId).then((badges) => twitchBadgesToObject.addAll(badges)).catchError(onError)),
        ffzApi.getBadges().then((badges) => _userToFFZBadges = badges).catchError(onError),
        sevenTvApi.getBadges().then((badges) => _userTo7TVBadges = badges).catchError(onError),
        bttvApi.getBadges().then((badges) => _userToBTTVBadges = badges).catchError(onError),
      ]);

  @action
  Future<void> userEmotesFuture({
    required List<String> emoteSets,
    required Map<String, String> headers,
    required Function onError,
  }) =>
      Future.wait(emoteSets.map((setId) => twitchApi.getEmotesSets(setId: setId, headers: headers).catchError(onError)))
          .then((emotes) => emotes.expand((list) => list).toList())
          .then((userEmotes) => _userEmoteToObject = {for (final emote in userEmotes) emote.name: emote}.asObservable());
}

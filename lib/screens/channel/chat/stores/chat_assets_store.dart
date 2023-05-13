import 'dart:convert';

import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'chat_assets_store.g.dart';

class ChatAssetsStore = ChatAssetsStoreBase with _$ChatAssetsStore;

abstract class ChatAssetsStoreBase with Store {
  final TwitchApi twitchApi;
  final BTTVApi bttvApi;
  final FFZApi ffzApi;
  final SevenTVApi sevenTVApi;

  /// Contains any custom FFZ mod and vip badges for the channel.
  RoomFFZ? ffzRoomInfo;

  @computed
  List<Emote> get bttvEmotes =>
      _emoteToObject.values.where((emote) => isBTTV(emote)).toList();

  @computed
  List<Emote> get ffzEmotes =>
      _emoteToObject.values.where((emote) => isFFZ(emote)).toList();

  @computed
  List<Emote> get sevenTVEmotes =>
      _emoteToObject.values.where((emote) => is7TV(emote)).toList();

  /// The map of badges ids to their object representation.
  final twitchBadgesToObject = ObservableMap<String, ChatBadge>();

  @readonly
  var _recentEmotes = ObservableList<Emote>();

  /// The map of emote words to their image or GIF URL. May be used by anyone in the chat.
  @readonly
  var _emoteToObject = <String, Emote>{};

  /// The emotes that are "owned" and may be used by the current user.
  @readonly
  // ignore: prefer_final_fields
  var _userEmoteToObject = <String, Emote>{};

  /// The Twitch emote types mapped to their emotes (i.e., global, specific channels, unlocked).
  @readonly
  // ignore: prefer_final_fields
  var _userEmoteSectionToEmotes = <String, List<Emote>>{};

  /// The map of user IDs to their FFZ badges.
  @readonly
  var _userToFFZBadges = <String, List<ChatBadge>>{};

  /// The map of user IDs to their 7TV badges.
  @readonly
  var _userTo7TVBadges = <String, List<ChatBadge>>{};

  /// The map of user IDs to their BTTV badge.
  @readonly
  var _userToBTTVBadges = <String, ChatBadge>{};

  /// Whether or not the emote menu is visible.
  @observable
  var showEmoteMenu = false;

  bool isBTTV(Emote emote) {
    return emote.type == EmoteType.bttvChannel ||
        emote.type == EmoteType.bttvGlobal ||
        emote.type == EmoteType.bttvShared;
  }

  bool isFFZ(Emote emote) {
    return emote.type == EmoteType.ffzChannel ||
        emote.type == EmoteType.ffzGlobal;
  }

  bool is7TV(Emote emote) {
    return emote.type == EmoteType.sevenTVChannel ||
        emote.type == EmoteType.sevenTVGlobal;
  }

  late final ReactionDisposer _disposeReaction;

  ChatAssetsStoreBase({
    required this.twitchApi,
    required this.bttvApi,
    required this.ffzApi,
    required this.sevenTVApi,
  });

  @action
  Future<void> init() async {
    // Retrieve the instance that will allow us to retrieve local search history.
    final prefs = await SharedPreferences.getInstance();

    _recentEmotes = prefs
            .getStringList('recent_emotes')
            ?.map((emoteJson) => Emote.fromJson(jsonDecode(emoteJson)))
            .toList()
            .asObservable() ??
        ObservableList<Emote>();

    _disposeReaction = autorun((_) {
      if (_recentEmotes.length > 48) _recentEmotes.removeLast();
      prefs.setStringList('recent_emotes',
          _recentEmotes.map((emote) => jsonEncode(emote)).toList());
    });
  }

  /// Fetches global and channel assets (badges and emotes) and stores them in [_emoteToUrl]
  @action
  Future<void> assetsFuture({
    required String channelId,
    required Map<String, String> headers,
    required Function onEmoteError,
    required Function onBadgeError,
  }) =>
      // Fetch the global and channel's assets (emotes & badges).
      // Async awaits are placed in a list so they are performed in parallel.
      Future.wait([
        emotesFuture(
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
        twitchApi
            .getEmotesChannel(id: channelId, headers: headers)
            .catchError(onError),
        sevenTVApi.getEmotesGlobal().catchError(onError),
        sevenTVApi.getEmotesChannel(id: channelId).catchError(onError),
        ffzApi.getRoomInfo(id: channelId).then((ffzRoom) {
          final (roomInfo, emotes) = ffzRoom;

          ffzRoomInfo = roomInfo;
          return emotes;
        }).catchError(onError),
      ]).then((assets) => assets.expand((list) => list)).then((emotes) =>
          _emoteToObject = {for (final emote in emotes) emote.name: emote});

  @action
  Future<void> badgesFuture({
    required String channelId,
    required Map<String, String> headers,
    required Function onError,
  }) =>
      Future.wait([
        // Get global badges first, then channel badges to avoid badge conflicts.
        // We want the channel badges to override the global badges.
        twitchApi
            .getBadgesGlobal(headers: headers)
            .then((badges) => twitchBadgesToObject.addAll(badges))
            .then((_) => twitchApi
                .getBadgesChannel(id: channelId, headers: headers)
                .then((badges) => twitchBadgesToObject.addAll(badges))
                .catchError(onError)),
        ffzApi
            .getBadges()
            .then((badges) => _userToFFZBadges = badges)
            .catchError(onError),
        sevenTVApi
            .getBadges()
            .then((badges) => _userTo7TVBadges = badges)
            .catchError(onError),
        bttvApi
            .getBadges()
            .then((badges) => _userToBTTVBadges = badges)
            .catchError(onError),
      ]);

  @action
  Future<void> userEmotesFuture({
    required List<String> emoteSets,
    required Map<String, String> headers,
    required Function onError,
  }) async {
    final userEmotes = await Future.wait(emoteSets.map((setId) => twitchApi
        .getEmotesSets(setId: setId, headers: headers)
        .catchError(onError)));

    for (final emoteSet in userEmotes) {
      if (emoteSet.isNotEmpty) {
        if (emoteSet.first.type == EmoteType.twitchSub) {
          final owner = await twitchApi.getUser(
              id: emoteSet.first.ownerId, headers: headers);
          _userEmoteSectionToEmotes.update(
            owner.displayName,
            (existingEmoteSet) => [...existingEmoteSet, ...emoteSet],
            ifAbsent: () => emoteSet,
          );
        } else if (emoteSet.first.type == EmoteType.twitchGlobal) {
          _userEmoteSectionToEmotes.update(
            'Global Emotes',
            (existingEmoteSet) => [...existingEmoteSet, ...emoteSet],
            ifAbsent: () => emoteSet,
          );
        } else if (emoteSet.first.type == EmoteType.twitchUnlocked) {
          _userEmoteSectionToEmotes.update(
            'Unlocked Emotes',
            (existingEmoteSet) => [...existingEmoteSet, ...emoteSet],
            ifAbsent: () => emoteSet,
          );
        }

        for (final emote in emoteSet) {
          _userEmoteToObject[emote.name] = emote;
        }
      }
    }
  }

  void dispose() => _disposeReaction();
}

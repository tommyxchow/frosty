import 'dart:convert';

import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/shared_chat_session.dart';
import 'package:frosty/models/user.dart';
import 'package:frosty/stores/global_assets_store.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'chat_assets_store.g.dart';

class ChatAssetsStore = ChatAssetsStoreBase with _$ChatAssetsStore;

abstract class ChatAssetsStoreBase with Store {
  final TwitchApi twitchApi;
  final BTTVApi bttvApi;
  final FFZApi ffzApi;
  final SevenTVApi sevenTVApi;
  final GlobalAssetsStore globalAssetsStore;

  /// Contains any custom FFZ mod and vip badges for the channel.
  RoomFFZ? ffzRoomInfo;

  String? sevenTvEmoteSetId;

  /// Tracks shared chat participant channels that we've already loaded assets for.
  final Set<String> _loadedSharedChannelIds = <String>{};

  /// Optional: Track 7TV set ids for shared chat participants (keyed by broadcaster id).
  final sharedSevenTvSetIds = ObservableMap<String, String>();

  final channelIdToUserTwitch = ObservableMap<String, UserTwitch>();

  @computed
  List<Emote> get bttvEmotes =>
      emoteToObject.values.where((emote) => isBTTV(emote)).toList();

  @computed
  List<Emote> get ffzEmotes =>
      emoteToObject.values.where((emote) => isFFZ(emote)).toList();

  @computed
  List<Emote> get sevenTVEmotes =>
      emoteToObject.values.where((emote) => is7TV(emote)).toList();

  @readonly
  var _recentEmotes = ObservableList<Emote>();

  /// Channel-specific emotes only (not global).
  @readonly
  var _channelEmoteToObject = ObservableMap<String, Emote>();

  /// Channel-specific Twitch badges (overrides globals).
  @readonly
  var _channelTwitchBadges = <String, ChatBadge>{};

  /// Combined emotes: global + channel. Channel emotes take precedence.
  @computed
  Map<String, Emote> get emoteToObject {
    final combined = Map<String, Emote>.from(globalAssetsStore.globalEmoteMap);
    combined.addAll(_channelEmoteToObject);
    return combined;
  }

  /// Combined Twitch badges: global + channel. Channel badges take precedence.
  @computed
  Map<String, ChatBadge> get twitchBadgesToObject {
    final combined = Map<String, ChatBadge>.from(
      globalAssetsStore.twitchGlobalBadges,
    );
    combined.addAll(_channelTwitchBadges);
    return combined;
  }

  /// The emotes that are "owned" and may be used by the current user.
  @readonly
  // ignore: prefer_final_fields
  var _userEmoteToObject = <String, Emote>{};

  /// The Twitch emote types mapped to their emotes (i.e., global, specific channels, unlocked).
  @readonly
  // ignore: prefer_final_fields
  var _userEmoteSectionToEmotes = <String, List<Emote>>{};

  /// The map of user IDs to their FFZ badges (from global store).
  Map<String, List<ChatBadge>> get userToFFZBadges =>
      globalAssetsStore.ffzBadges;

  /// The map of user IDs to their 7TV badges.
  @readonly
  var _userTo7TVBadges = <String, List<ChatBadge>>{};

  /// The map of user IDs to their BTTV badge (from global store).
  Map<String, ChatBadge> get userToBTTVBadges => globalAssetsStore.bttvBadges;

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
    required this.globalAssetsStore,
  });

  @action
  Future<void> init() async {
    // Retrieve the instance that will allow us to retrieve local search history.
    final prefs = await SharedPreferences.getInstance();

    _recentEmotes =
        prefs
            .getStringList('recent_emotes')
            ?.map((emoteJson) => Emote.fromJson(jsonDecode(emoteJson)))
            .toList()
            .asObservable() ??
        ObservableList<Emote>();

    _disposeReaction = autorun((_) {
      if (_recentEmotes.length > 48) _recentEmotes.removeLast();
      prefs.setStringList(
        'recent_emotes',
        _recentEmotes.map((emote) => jsonEncode(emote)).toList(),
      );
    });
  }

  /// Fetches channel-specific assets (badges and emotes).
  /// Global assets are loaded via [globalAssetsStore] and combined automatically.
  @action
  Future<void> assetsFuture({
    required String channelId,
    required Map<String, String> headers,
    required Function onEmoteError,
    required Function onBadgeError,
    bool showTwitchEmotes = true,
    bool showTwitchBadges = true,
    bool show7TVEmotes = true,
    bool showBTTVEmotes = true,
    bool showBTTVBadges = true,
    bool showFFZEmotes = true,
    bool showFFZBadges = true,
  }) async {
    // Fetch global (cached) and channel-specific assets in parallel
    await Future.wait([
      // Global assets (cached across all tabs - only fetches once)
      globalAssetsStore.ensureLoaded(
        showTwitchEmotes: showTwitchEmotes,
        showTwitchBadges: showTwitchBadges,
        show7TVEmotes: show7TVEmotes,
        showBTTVEmotes: showBTTVEmotes,
        showBTTVBadges: showBTTVBadges,
        showFFZEmotes: showFFZEmotes,
        showFFZBadges: showFFZBadges,
      ),
      // Channel-specific emotes
      Future.wait([
            if (showTwitchEmotes)
              twitchApi
                  .getEmotesChannel(id: channelId)
                  .then((emotes) {
                    _userEmoteSectionToEmotes.update(
                      'Channel Emotes',
                      (existingEmoteSet) => [...existingEmoteSet, ...emotes],
                      ifAbsent: () => emotes.toList(),
                    );
                    return emotes;
                  })
                  .catchError(onEmoteError),
            if (show7TVEmotes)
              sevenTVApi
                  .getEmotesChannel(id: channelId)
                  .then((data) {
                    final (setId, emotes) = data;
                    sevenTvEmoteSetId = setId;
                    return emotes;
                  })
                  .catchError(onEmoteError),
            if (showBTTVEmotes)
              bttvApi.getEmotesChannel(id: channelId).catchError(onEmoteError),
            if (showFFZEmotes)
              ffzApi
                  .getRoomInfo(id: channelId)
                  .then((ffzRoom) {
                    final (roomInfo, emotes) = ffzRoom;
                    ffzRoomInfo = roomInfo;
                    return emotes;
                  })
                  .catchError(onEmoteError),
          ])
          .then((assets) => assets.expand((list) => list))
          .then(
            (emotes) => _channelEmoteToObject = <String, Emote>{
              for (final emote in emotes) emote.name: emote,
            }.asObservable(),
          ),
      // Channel badges (Twitch only - FFZ/BTTV badges are global)
      if (showTwitchBadges)
        twitchApi
            .getBadgesChannel(id: channelId)
            .then((badges) => _channelTwitchBadges = badges)
            .catchError(onBadgeError),
    ]);
  }

  /// Fetch and merge assets for all participants in a shared chat session.
  /// Safe to call multiple times; only new participant channels will be fetched.
  @action
  Future<void> fetchSharedChatAssets({
    required String channelId,
    required Map<String, String> headers,
    required Function onEmoteError,
    required Function onBadgeError,
    bool showTwitchEmotes = true,
    bool showTwitchBadges = true,
    bool show7TVEmotes = true,
    bool showBTTVEmotes = true,
    bool showFFZEmotes = true,
    bool showFFZBadges = true,
    bool force = false,
  }) async {
    if (force) {
      _loadedSharedChannelIds.clear();
      sharedSevenTvSetIds.clear();
    }

    final newParticipantIds = await populateSharedChatParticipants(
      channelId: channelId,
      onBadgeError: onBadgeError,
    );

    if (newParticipantIds.isEmpty) return;

    // Fetch emotes and badges for all new participants in parallel.
    final futures = <Future<void>>[];

    // Add emote futures for each participant.
    futures.addAll(
      newParticipantIds.map(
        (id) =>
            _fetchEmotesForChannel(
              id,
              onEmoteError: onEmoteError,
              showTwitchEmotes: showTwitchEmotes,
              show7TVEmotes: show7TVEmotes,
              showBTTVEmotes: showBTTVEmotes,
              showFFZEmotes: showFFZEmotes,
            ).then((emotes) {
              for (final emote in emotes) {
                _channelEmoteToObject[emote.name] = emote;
              }
            }),
      ),
    );

    // Add badge futures for each participant.
    if (showTwitchBadges) {
      futures.addAll(
        newParticipantIds.map(
          (id) => _fetchBadgesForChannel(id, onBadgeError: onBadgeError),
        ),
      );
    }

    await Future.wait(futures);
  }

  /// Load and cache shared chat participants for a broadcaster.
  /// Returns the list of new participant broadcaster IDs (deduped).
  @action
  Future<List<String>> populateSharedChatParticipants({
    required String channelId,
    required Function onBadgeError,
  }) async {
    SharedChatSession? sharedSession;
    try {
      sharedSession = await twitchApi.getSharedChatSession(
        broadcasterId: channelId,
      );
    } catch (e) {
      onBadgeError(e);
      return <String>[];
    }

    if (sharedSession == null) return <String>[];

    final newParticipantIds = <String>[];
    for (final participant in sharedSession.participants) {
      final id = participant.broadcasterId;
      if (_loadedSharedChannelIds.add(id)) {
        newParticipantIds.add(id);
      }
    }

    // Fetch user profiles concurrently.
    if (newParticipantIds.isNotEmpty) {
      await Future.wait(
        newParticipantIds.map((id) async {
          try {
            final user = await twitchApi.getUser(id: id);
            channelIdToUserTwitch[id] = user;
          } catch (e) {
            onBadgeError(e);
          }
        }),
      );
    }

    return newParticipantIds;
  }

  Future<List<Emote>> _fetchEmotesForChannel(
    String id, {
    required Function onEmoteError,
    bool showTwitchEmotes = true,
    bool show7TVEmotes = true,
    bool showBTTVEmotes = true,
    bool showFFZEmotes = true,
  }) async {
    final futures = <Future<List<Emote>>>[];

    if (showTwitchEmotes) {
      futures.add(twitchApi.getEmotesChannel(id: id).catchError(onEmoteError));
    }
    if (show7TVEmotes) {
      futures.add(
        sevenTVApi
            .getEmotesChannel(id: id)
            .then((data) {
              final (setId, emotes) = data;
              sharedSevenTvSetIds[id] = setId;
              return emotes;
            })
            .catchError(onEmoteError),
      );
    }
    if (showBTTVEmotes) {
      futures.add(bttvApi.getEmotesChannel(id: id).catchError(onEmoteError));
    }
    if (showFFZEmotes) {
      futures.add(
        ffzApi
            .getRoomInfo(id: id)
            .then((ffzRoom) {
              final (roomInfoIgnored, emotes) = ffzRoom;
              return emotes;
            })
            .catchError(onEmoteError),
      );
    }

    final lists = await Future.wait(futures);
    return lists.expand((e) => e).toList();
  }

  Future<void> _fetchBadgesForChannel(
    String id, {
    required Function onBadgeError,
  }) async {
    try {
      final badges = await twitchApi.getBadgesChannel(id: id);
      _channelTwitchBadges = {..._channelTwitchBadges, ...badges};
    } catch (e) {
      onBadgeError(e);
    }
  }

  @action
  Future<void> userEmotesFuture({
    required List<String> emoteSets,
    required Map<String, String> headers,
    required Function onError,
  }) async {
    final userEmotes = await Future.wait(
      emoteSets.map(
        (setId) => twitchApi.getEmotesSets(setId: setId).catchError(onError),
      ),
    );

    for (final emoteSet in userEmotes) {
      if (emoteSet.isNotEmpty) {
        if (emoteSet.first.type == EmoteType.twitchSub) {
          final ownerId = emoteSet.first.ownerId;

          // Check for tuurbo emote sets (e.g., monkey set).
          if (ownerId == 'twitch') {
            _userEmoteSectionToEmotes.update(
              'Global Emotes',
              (existingEmoteSet) => [...existingEmoteSet, ...emoteSet],
              ifAbsent: () => emoteSet,
            );
          } else {
            final owner = await twitchApi.getUser(id: ownerId);
            _userEmoteSectionToEmotes.update(
              owner.displayName,
              (existingEmoteSet) => [...existingEmoteSet, ...emoteSet],
              ifAbsent: () => emoteSet,
            );
          }
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

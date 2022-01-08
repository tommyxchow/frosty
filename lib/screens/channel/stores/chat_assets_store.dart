import 'package:frosty/api/bttv_api.dart';
import 'package:frosty/api/ffz_api.dart';
import 'package:frosty/api/seventv_api.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/user.dart';
import 'package:mobx/mobx.dart';

part 'chat_assets_store.g.dart';

class ChatAssetsStore = _ChatAssetsStoreBase with _$ChatAssetsStore;

abstract class _ChatAssetsStoreBase with Store {
  /// Contains any custom FFZ mod and vip badges for the channel.
  RoomFFZ? ffzRoomInfo;

  @computed
  List<Emote> get bttvEmotes => _emoteToObject.values.where((emote) => isBTTV(emote)).toList();

  @computed
  List<Emote> get ffzEmotes => _emoteToObject.values.where((emote) => isFFZ(emote)).toList();

  @computed
  List<Emote> get sevenTvEmotes => _emoteToObject.values.where((emote) => is7TV(emote)).toList();

  /// The map of badges ids to their object representation.
  final twitchBadgesToObject = ObservableMap<String, BadgeInfoTwitch>();

  /// The map of emote words to their image or GIF URL. May be used by anyone in the chat.
  @readonly
  var _emoteToObject = <String, Emote>{};

  /// The emotes that are "owned" and may be used by the current user.
  @readonly
  var _userEmoteToObject = <String, Emote>{};

  /// The map of usernames to their FFZ badges.
  @readonly
  var _userToFFZBadges = <String, List<BadgeInfoFFZ>>{};

  /// The map of usernames to their 7TV badges.
  @readonly
  var _userTo7TVBadges = <String, List<BadgeInfo7TV>>{};

  /// The map of usernames to their BTTV badge.
  @readonly
  var _userToBTTVBadges = <String, BadgeInfoBTTV>{};

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

  /// Fetches global and channel assets (badges and emotes) and stores them in [_emoteToUrl]
  @action
  Future<void> getAssets({required String channelName, required Map<String, String> headers}) async {
    // Fetch the desired channel/user's information.
    final channelInfo = await Twitch.getUser(userLogin: channelName, headers: headers);

    if (channelInfo != null) {
      // Fetch the global and channel's assets (emotes & badges).
      // Async awaits are placed in a list so they are performed in parallel.

      await Future.wait([
        getEmotes(channelInfo: channelInfo, headers: headers),
        getBadges(channelInfo: channelInfo, headers: headers),
      ]);
    }
  }

  @action
  Future<void> getEmotes({required UserTwitch channelInfo, required Map<String, String> headers}) async {
    final assets = await Future.wait([
      FFZ.getEmotesGlobal(),
      BTTV.getEmotesGlobal(),
      BTTV.getEmotesChannel(id: channelInfo.id),
      Twitch.getEmotesGlobal(headers: headers),
      Twitch.getEmotesChannel(id: channelInfo.id, headers: headers),
      SevenTV.getEmotesGlobal(),
      SevenTV.getEmotesChannel(user: channelInfo.login),
      FFZ.getRoomInfo(name: channelInfo.login).then((ffzRoom) {
        ffzRoomInfo = ffzRoom?.item1;
        return ffzRoom?.item2 ?? <Emote>[];
      }),
    ]);

    final emotes = assets.expand((list) => list);

    _emoteToObject = {for (final emote in emotes) emote.name: emote};
  }

  @action
  Future<void> getBadges({required UserTwitch channelInfo, required Map<String, String> headers}) async => await Future.wait([
        Twitch.getBadgesGlobal().then((badges) => twitchBadgesToObject.addAll(badges)),
        Twitch.getBadgesChannel(id: channelInfo.id).then((badges) => twitchBadgesToObject.addAll(badges)),
        FFZ.getBadges().then((badges) => _userToFFZBadges = badges ?? {}),
        SevenTV.getBadges().then((badges) => _userTo7TVBadges = badges ?? {}),
        BTTV.getBadges().then((badges) => _userToBTTVBadges = badges ?? {}),
      ]);

  @action
  Future<void> getUserEmotes({required List<String> emoteSets, required Map<String, String> headers}) async =>
      await Future.wait(emoteSets.map((setId) => Twitch.getEmotesSets(setId: setId, headers: headers)))
          .then((emotes) => emotes.expand((list) => list).toList())
          .then((userEmotes) => _userEmoteToObject = {for (final emote in userEmotes) emote.name: emote}.asObservable());
}

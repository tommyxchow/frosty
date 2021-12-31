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
  /// The map of emote words to their image or GIF URL. May be used by anyone in the chat.
  final emoteToObject = ObservableMap<String, Emote>();

  @computed
  List<Emote> get bttvEmotes => emoteToObject.values.where((emote) => isBTTV(emote)).toList();

  @computed
  List<Emote> get ffzEmotes => emoteToObject.values.where((emote) => isFFZ(emote)).toList();

  @computed
  List<Emote> get sevenTvEmotes => emoteToObject.values.where((emote) => is7TV(emote)).toList();

  /// The emotes that are "owned" and may be used by the current user.
  @readonly
  var _userEmoteToObject = ObservableMap<String, Emote>();

  /// The map of badges ids to their object representation.
  final twitchBadgesToObject = <String, BadgeInfoTwitch>{};

  /// The map of usernames to their FFZ badges.
  final userToFFZBadges = <String, List<BadgeInfoFFZ>>{};

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
      final assets = [
        ...await FFZ.getEmotesGlobal(),
        ...await FFZ.getEmotesChannel(id: channelInfo.id),
        ...await BTTV.getEmotesGlobal(),
        ...await BTTV.getEmotesChannel(id: channelInfo.id),
        ...await Twitch.getEmotesGlobal(headers: headers),
        ...await Twitch.getEmotesChannel(id: channelInfo.id, headers: headers),
        ...await SevenTV.getEmotesGlobal(),
        ...await SevenTV.getEmotesChannel(user: channelInfo.login)
      ];

      for (final emote in assets) {
        emoteToObject[emote.name] = emote;
      }

      final badges = [
        await Twitch.getBadgesGlobal(),
        await Twitch.getBadgesChannel(id: channelInfo.id),
      ];

      for (final map in badges) {
        if (map != null) {
          twitchBadgesToObject.addAll(map);
        }
      }

      final ffzBadges = await FFZ.getBadges();
      if (ffzBadges != null) userToFFZBadges.addAll(ffzBadges);
    }
  }

  @action
  Future<void> getUserEmotes({List<String>? emoteSets, required Map<String, String> headers}) async {
    if (emoteSets != null) {
      final userEmotes = <Emote>[];
      for (final setId in emoteSets) {
        userEmotes.addAll(await Twitch.getEmotesSets(setId: setId, headers: headers));
      }

      _userEmoteToObject = {for (final emote in userEmotes) emote.name: emote}.asObservable();
    }
  }
}

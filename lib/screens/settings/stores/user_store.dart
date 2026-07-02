import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/user.dart';
import 'package:mobx/mobx.dart';

part 'user_store.g.dart';

class UserStore = UserStoreBase with _$UserStore;

abstract class UserStoreBase with Store {
  final TwitchApi twitchApi;

  /// The current user's info.
  @readonly
  UserTwitch? _details;

  /// The user's list of blocked users.
  @readonly
  var _blockedUsers = ObservableList<UserBlockedTwitch>();

  /// The list of channel IDs the user moderates.
  @readonly
  var _moderatedChannels = ObservableList<String>();

  ReactionDisposer? _disposeReaction;

  UserStoreBase({required this.twitchApi});

  @action
  Future<void> init() async {
    // Get and update the current user's info.
    _details = await twitchApi.getUserInfo();

    // Get and update non-critical user info.
    // Don't use await because having a huge list of blocked users will block the UI.
    if (_details?.id != null) {
      twitchApi
          .getUserBlockedList(id: _details!.id)
          .then((blockedUsers) => _blockedUsers = blockedUsers.asObservable());
      twitchApi
          .getModeratedChannels(id: _details!.id)
          .then((channels) => _moderatedChannels = channels.asObservable());
    }

    _disposeReaction = autorun(
      (_) => _blockedUsers.sort((a, b) => a.userLogin.compareTo(b.userLogin)),
    );
  }

  @action
  Future<void> block({
    required String targetId,
    required String displayName,
  }) async {
    final success = await twitchApi.blockUser(userId: targetId);

    if (success) {
      _blockedUsers.add(UserBlockedTwitch(targetId, displayName, displayName));
    }
  }

  @action
  Future<void> unblock({required String targetId}) async {
    final success = await twitchApi.unblockUser(userId: targetId);
    if (success) await refreshBlockedUsers();
  }

  @action
  Future<void> refreshBlockedUsers() async => _blockedUsers =
      (await twitchApi.getUserBlockedList(id: _details!.id)).asObservable();

  bool isModerator(String channelId) {
    return _moderatedChannels.contains(channelId);
  }

  /// Whether the logged-in user can moderate [channelId] — either a moderator
  /// of that channel or its broadcaster (the broadcaster isn't in their own
  /// moderator list but can still use the moderation endpoints).
  bool canModerate(String channelId) =>
      _details?.id == channelId || isModerator(channelId);

  @action
  Future<bool> deleteMessage({
    required String broadcasterId,
    required String messageId,
  }) async {
    // Need the moderator ID and confirmed mod status for this channel.
    if (_details?.id == null || !canModerate(broadcasterId)) {
      return false;
    }
    return twitchApi.deleteChatMessage(
      broadcasterId: broadcasterId,
      moderatorId: _details!.id,
      messageId: messageId,
    );
  }

  @action
  Future<bool> banOrTimeoutUser({
    required String broadcasterId,
    required String userIdToBan,
    int? duration,
    String? reason,
  }) async {
    // Need the moderator ID and confirmed mod status for this channel.
    if (_details?.id == null || !canModerate(broadcasterId)) {
      return false;
    }
    return twitchApi.banUser(
      broadcasterId: broadcasterId,
      moderatorId: _details!.id,
      userIdToBan: userIdToBan,
      duration: duration,
      reason: reason,
    );
  }

  /// Removes a ban or timeout for [userIdToUnban] in the channel.
  @action
  Future<bool> unbanUser({
    required String broadcasterId,
    required String userIdToUnban,
  }) async {
    if (_details?.id == null || !canModerate(broadcasterId)) {
      return false;
    }
    return twitchApi.unbanUser(
      broadcasterId: broadcasterId,
      moderatorId: _details!.id,
      userId: userIdToUnban,
    );
  }

  @action
  void dispose() {
    _details = null;
    _blockedUsers.clear();
    _moderatedChannels.clear();
    if (_disposeReaction != null) _disposeReaction!();
  }
}

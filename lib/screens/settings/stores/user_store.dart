import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/user.dart';
import 'package:mobx/mobx.dart';

part 'user_store.g.dart';

class UserStore = UserStoreBase with _$UserStore;

abstract class UserStoreBase with Store {
  final TwitchApi twitchApi;

  /// Whether the active auth token includes Frosty's moderator OAuth scopes.
  final bool Function() hasModeratorScopes;

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

  UserStoreBase({
    required this.twitchApi,
    required this.hasModeratorScopes,
  });

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
      // Never hit moderated-channels Helix without moderator scopes — that 401
      // is what nags non-mod users after an app upgrade.
      if (hasModeratorScopes()) {
        twitchApi
            .getModeratedChannels(id: _details!.id)
            .then(
              (channels) => _moderatedChannels = channels.asObservable(),
            );
      } else {
        _moderatedChannels = ObservableList<String>();
      }
    }

    _disposeReaction?.call();
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

  /// Re-fetches which channels the user moderates. Mod status is otherwise only
  /// loaded once at login, so call this when entering a channel to reflect mod
  /// status granted or revoked since then.
  @action
  Future<void> refreshModeratedChannels() async {
    if (_details?.id == null || !hasModeratorScopes()) return;
    _moderatedChannels =
        (await twitchApi.getModeratedChannels(id: _details!.id)).asObservable();
  }

  bool isModerator(String channelId) {
    return _moderatedChannels.contains(channelId);
  }

  /// Whether the logged-in user can moderate [channelId] — either a moderator
  /// of that channel or its broadcaster (the broadcaster isn't in their own
  /// moderator list but can still use the moderation endpoints).
  ///
  /// Role only — does not require moderator OAuth scopes. Use
  /// [canPerformModeratorActions] before calling Helix.
  bool canModerate(String channelId) =>
      _details?.id == channelId || isModerator(channelId);

  /// Role + moderator OAuth scopes — safe to call Helix mod endpoints.
  bool canPerformModeratorActions(String channelId) =>
      _details?.id != null &&
      hasModeratorScopes() &&
      canModerate(channelId);

  @action
  Future<bool> deleteMessage({
    required String broadcasterId,
    required String messageId,
  }) async {
    if (!canPerformModeratorActions(broadcasterId)) return false;
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
    if (!canPerformModeratorActions(broadcasterId)) return false;
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
    if (!canPerformModeratorActions(broadcasterId)) return false;
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
    _disposeReaction?.call();
    _disposeReaction = null;
  }
}

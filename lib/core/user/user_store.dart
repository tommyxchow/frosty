import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/models/user.dart';
import 'package:mobx/mobx.dart';

part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;

abstract class _UserStoreBase with Store {
  final TwitchApi twitchApi;

  /// The current user's info.
  @readonly
  UserTwitch? _details;

  /// The user's list of blocked users.
  @readonly
  var _blockedUsers = ObservableList<UserBlockedTwitch>();

  ReactionDisposer? _disposeReaction;

  _UserStoreBase({required this.twitchApi});

  @action
  Future<void> init({required Map<String, String> headers}) async {
    // Get and update the current user's info.
    _details = await twitchApi.getUserInfo(headers: headers);

    // Get and update the current user's list of blocked users.
    if (_details?.id != null) _blockedUsers = (await twitchApi.getUserBlockedList(id: _details!.id, headers: headers)).asObservable();

    _disposeReaction = autorun((_) => _blockedUsers.sort((a, b) => a.userLogin.compareTo(b.userLogin)));
  }

  @action
  Future<void> block({
    required String targetId,
    required String displayName,
    required Map<String, String> headers,
  }) async {
    final success = await twitchApi.blockUser(userId: targetId, headers: headers);

    if (success) _blockedUsers.add(UserBlockedTwitch(targetId, displayName, displayName));
  }

  @action
  Future<void> unblock({required String targetId, required Map<String, String> headers}) async {
    final success = await twitchApi.unblockUser(userId: targetId, headers: headers);
    if (success) await refreshBlockedUsers(headers: headers);
  }

  @action
  Future<void> refreshBlockedUsers({required Map<String, String> headers}) async =>
      _blockedUsers = (await twitchApi.getUserBlockedList(id: _details!.id, headers: headers)).asObservable();

  @action
  void dispose() {
    _details = null;
    _blockedUsers.clear();
    if (_disposeReaction != null) _disposeReaction!();
  }
}

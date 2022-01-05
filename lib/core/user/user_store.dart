import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/models/user.dart';
import 'package:mobx/mobx.dart';

part 'user_store.g.dart';

class UserStore = _UserStoreBase with _$UserStore;

abstract class _UserStoreBase with Store {
  /// The current user's info.
  @readonly
  UserTwitch? _details;

  /// The user's list of blocked users.
  @readonly
  var _blockedUsers = ObservableList<UserBlockedTwitch>();

  ReactionDisposer? disposeReaction;

  @action
  Future<void> init({required Map<String, String> headers}) async {
    // Get and update the current user's info.
    _details = await Twitch.getUserInfo(headers: headers);

    // Get and update the current user's list of blocked users.
    if (_details?.id != null) _blockedUsers = (await Twitch.getUserBlockedList(id: _details!.id, headers: headers)).asObservable();

    disposeReaction = autorun((_) => _blockedUsers.sort((a, b) => a.userLogin.compareTo(b.userLogin)));
  }

  @action
  Future<void> block({required String targetId, required Map<String, String> headers}) async {
    final success = await Twitch.blockUser(userId: targetId, headers: headers);
    // Add a slight delay between requests, otherwise the blocked list won't properly update.
    // Weird behavior, might be something to do with PUT request and time to create and update resource?
    await Future.delayed(const Duration(milliseconds: 200));
    if (success) await refreshBlockedUsers(headers: headers);
  }

  @action
  Future<void> unblock({required String targetId, required Map<String, String> headers}) async {
    final success = await Twitch.unblockUser(userId: targetId, headers: headers);
    if (success) await refreshBlockedUsers(headers: headers);
  }

  @action
  Future<void> refreshBlockedUsers({required Map<String, String> headers}) async =>
      _blockedUsers = (await Twitch.getUserBlockedList(id: _details!.id, headers: headers)).asObservable();

  @action
  void dispose() {
    _details = null;
    _blockedUsers.clear();
    if (disposeReaction != null) disposeReaction!();
  }
}

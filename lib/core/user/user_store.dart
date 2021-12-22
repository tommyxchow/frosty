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

  @action
  Future<void> init({required Map<String, String> headers}) async {
    // Get and update the current user's info.
    _details = await Twitch.getUserInfo(headers: headers);

    // Get and update the current user's list of blocked users.
    if (_details?.id != null) _blockedUsers = (await Twitch.getUserBlockedList(id: _details!.id, headers: headers)).asObservable();
  }

  @action
  void dispose() {
    _details = null;
    _blockedUsers.clear();
  }
}

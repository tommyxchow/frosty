import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/models/chatters.dart';
import 'package:frosty/models/irc_message.dart';
import 'package:mobx/mobx.dart';

part 'chat_details_store.g.dart';

class ChatDetailsStore = _ChatDetailsStoreBase with _$ChatDetailsStore;

abstract class _ChatDetailsStoreBase with Store {
  /// The rules and modes being used in the chat.
  @observable
  var roomState = const ROOMSTATE();

  /// The list and types of chatters in the chat room.
  @readonly
  ChatUsers? _chatUsers;

  @observable
  var showJumpButton = false;

  @observable
  var filterText = '';

  @computed
  Iterable<List<String>> get filteredUsers => [
        _chatUsers!.chatters.broadcaster,
        _chatUsers!.chatters.staff,
        _chatUsers!.chatters.admins,
        _chatUsers!.chatters.globalMods,
        _chatUsers!.chatters.moderators,
        _chatUsers!.chatters.vips,
        _chatUsers!.chatters.viewers,
      ].map((e) => e.where((user) => user.contains(filterText)).toList());

  @action
  Future<void> updateChatters(String userLogin) async => _chatUsers = await Twitch.getChatters(userLogin: userLogin);
}

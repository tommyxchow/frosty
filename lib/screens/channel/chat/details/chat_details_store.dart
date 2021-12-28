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
  ChatUsers? _chatters;

  @action
  Future<void> updateChatters(String userLogin) async {
    _chatters = await Twitch.getChatters(userLogin: userLogin);
  }
}

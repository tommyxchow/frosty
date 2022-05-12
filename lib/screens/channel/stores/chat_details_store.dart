import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/models/chatters.dart';
import 'package:frosty/models/irc.dart';
import 'package:mobx/mobx.dart';

part 'chat_details_store.g.dart';

class ChatDetailsStore = ChatDetailsStoreBase with _$ChatDetailsStore;

abstract class ChatDetailsStoreBase with Store {
  final TwitchApi twitchApi;

  /// The rules and modes being used in the chat.
  @observable
  var roomState = const ROOMSTATE();

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

  /// The list and types of chatters in the chat room.
  @readonly
  ChatUsers? _chatUsers;

  @readonly
  String? _error;

  ChatDetailsStoreBase({required this.twitchApi});

  @action
  Future<void> updateChatters(String userLogin) async {
    try {
      _chatUsers = await twitchApi.getChatters(userLogin: userLogin);
      _error = null;
    } on SocketException {
      _error = 'Failed to connect :(';
    } catch (e) {
      debugPrint(e.toString());
      _error = e.toString();
    }
  }
}

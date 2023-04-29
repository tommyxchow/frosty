import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/chatters.dart';
import 'package:frosty/models/irc.dart';
import 'package:mobx/mobx.dart';

part 'chat_details_store.g.dart';

class ChatDetailsStore = ChatDetailsStoreBase with _$ChatDetailsStore;

abstract class ChatDetailsStoreBase with Store {
  final TwitchApi twitchApi;

  final String channelName;

  /// The scroll controller for handling the scroll to top button.
  final scrollController = ScrollController();

  /// The text controller for handling filtering the chatters.
  final textController = TextEditingController();

  /// The focus node for the textfield used for handling hiding/showing the cancel button.
  final textFieldFocusNode = FocusNode();

  /// The rules and modes being used in the chat.
  @observable
  var roomState = const ROOMSTATE();

  @observable
  var showJumpButton = false;

  /// The current text being used to filter the chatters.
  /// Changing this will automatically update [filteredUsers].
  @readonly
  var _filterText = '';

  /// The list and types of chatters in the chat room.
  @readonly
  ChatUsers? _chatUsers;

  @computed
  Iterable<List<String>> get filteredUsers => [
        _chatUsers!.chatters.broadcaster,
        _chatUsers!.chatters.staff,
        _chatUsers!.chatters.admins,
        _chatUsers!.chatters.globalMods,
        _chatUsers!.chatters.moderators,
        _chatUsers!.chatters.vips,
        _chatUsers!.chatters.viewers,
      ].map((e) => e.where((user) => user.contains(_filterText)).toList());

  @computed
  List<String> get allChatters => [
        ...?_chatUsers?.chatters.broadcaster,
        ...?_chatUsers?.chatters.staff,
        ...?_chatUsers?.chatters.admins,
        ...?_chatUsers?.chatters.globalMods,
        ...?_chatUsers?.chatters.moderators,
        ...?_chatUsers?.chatters.vips,
        ...?_chatUsers?.chatters.viewers,
      ];

  @readonly
  String? _error;

  ChatDetailsStoreBase({required this.twitchApi, required this.channelName}) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge ||
          scrollController.position.outOfRange) {
        showJumpButton = false;
      } else {
        showJumpButton = true;
      }
    });

    textController.addListener(() => _filterText = textController.text);

    updateChatters();
  }

  @action
  Future<void> updateChatters() async {
    try {
      _chatUsers = await twitchApi.getChatters(userLogin: channelName);
      _error = null;
    } on SocketException {
      _error = 'Failed to connect';
    } catch (e) {
      debugPrint(e.toString());
      _error = e.toString();
    }
  }

  void dispose() {
    scrollController.dispose();
    textController.dispose();
    textFieldFocusNode.dispose();
  }
}

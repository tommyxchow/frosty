import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:frosty/apis/twitch_api.dart';
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
  final chatUsers = SplayTreeSet<String>();

  @computed
  Iterable<String> get filteredUsers =>
      chatUsers.where((user) => user.contains(_filterText));

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
  }

  void dispose() {
    scrollController.dispose();
    textController.dispose();
    textFieldFocusNode.dispose();
  }
}

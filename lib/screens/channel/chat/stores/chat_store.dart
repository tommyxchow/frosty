import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/events.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_assets_store.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/utils.dart';
import 'package:mobx/mobx.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

/// The store and view-model for chat-related activities.
class ChatStore = ChatStoreBase with _$ChatStore;

abstract class ChatStoreBase with Store {
  /// The total maximum amount of messages in chat.
  static const _messageLimit = 5000;

  /// The maximum ammount of messages to render when autoscroll is enabled.
  static const _renderMessageLimit = 100;

  final TwitchApi twitchApi;

  /// The amount of messages to free (remove) when the [_messageLimit] is reached.
  final _messagesToRemove = (_messageLimit * 0.2).toInt();

  /// The provided auth store to determine login status, get the token, and use the headers for requests.
  final AuthStore auth;

  /// The provided setting store to account for any user-defined behaviors.
  final SettingsStore settings;

  /// The focus node for the textfield to allow for showing and hiding the keyboard/focus.
  final textFieldFocusNode = FocusNode();

  /// The name of the channel to connect to.
  final String channelName;

  /// The channel's ID for API requests.
  final String channelId;

  /// The channel's display name to show on widgets.
  final String displayName;

  var _shouldDisconnect = false;

  /// The Twitch IRC WebSocket channel.
  WebSocketChannel? _channel;

  /// The subscription that handles the WebSocket connection.
  StreamSubscription? _channelListener;

  WebSocketChannel? _sevenTVChannel;

  /// The subscription that handles the 7TV WebSocket connection.
  StreamSubscription? _sevenTVChannelListener;

  static const _maxRetries = 5;

  // The retry counter for exponential backoff.
  var _retries = 0;

  // The current time to wait between retries for exponential backoff.
  var _backoffTime = 0;

  /// The scroll controller that controls auto-scroll and resume-scroll behavior.
  final scrollController = ScrollController();

  /// The text controller that handles the TextField inputs and sending of messages.
  final textController = TextEditingController();

  /// The chat details store responsible for the chat modes and users in chat.
  final ChatDetailsStore chatDetailsStore;

  /// The assets store responsible for badges, emotes, and the emote menu.
  final ChatAssetsStore assetsStore;

  /// Requested message to be sent by the user. Will only be sent on receipt of a USERNOTICE command.
  IRCMessage? toSend;

  /// The list of reaction disposer functions that will be used later when disposing.
  final reactions = <ReactionDisposer>[];

  /// The periodic timer used for batching chat message re-renders.
  Timer? _messageBufferTimer;

  /// The list of chat messages to add once autoscroll is resumed.
  /// This is used as an optimization to prevent the list from being updated/shifted while the user is scrolling.
  final messageBuffer = ObservableList<IRCMessage>();

  /// Timer used for dismissing the notification.
  Timer? _notificationTimer;

  /// The current timer for the sleep timer if active.
  Timer? sleepTimer;

  /// The time remaining for the sleep timer.
  @observable
  var timeRemaining = const Duration();

  /// A notification message to display above the chat.
  @readonly
  String? _notification;

  /// The list of chat messages to render and display.
  @readonly
  var _messages = ObservableList<IRCMessage>();

  /// The list of chat messages that should be rendered. Used to prevent jank when resuming scroll.
  @computed
  List<IRCMessage> get renderMessages {
    // If autoscroll is disabled, render ALL messages in chat.
    // The second condition is to prevent an out of index error with sublist.
    if (!_autoScroll || _messages.length < _renderMessageLimit) {
      return _messages;
    }

    // When autoscroll is enabled, only show the first [_renderMessageLimit] messages.
    // This will improve performance by only rendering a limited amount of messages
    // instead of the entire history at all times.
    return _messages.sublist(_messages.length - _renderMessageLimit);
  }

  /// If the chat should automatically scroll/jump to the latest message.
  @readonly
  var _autoScroll = true;

  @readonly
  var _inputText = '';

  @readonly
  var _showSendButton = false;

  @readonly
  var _showEmoteAutocomplete = false;

  @readonly
  var _showMentionAutocomplete = false;

  /// The logged-in user's appearance in chat.
  @readonly
  var _userState = const USERSTATE();

  @observable
  var expandChat = false;

  @observable
  IRCMessage? replyingToMessage;

  ChatStoreBase({
    required this.twitchApi,
    required this.auth,
    required this.chatDetailsStore,
    required this.assetsStore,
    required this.settings,
    required this.channelName,
    required this.channelId,
    required this.displayName,
  }) {
    // Enable wakelock to prevent the chat from sleeping.
    if (settings.chatOnlyPreventSleep) WakelockPlus.enable();

    // Create a reaction that will reconnect to chat when logging in or out.
    // Closing the channel will trigger a reconnect with the new credentials.
    reactions.add(
      reaction(
        (_) => auth.isLoggedIn,
        (_) => _channel?.sink.close(1000),
      ),
    );

    reactions.add(
      reaction(
        (_) => [
          settings.showTwitchEmotes,
          settings.showTwitchBadges,
          settings.show7TVEmotes,
          settings.showBTTVEmotes,
          settings.showBTTVBadges,
          settings.showFFZEmotes,
          settings.showFFZBadges,
        ],
        (_) {
          if (!settings.show7TVEmotes) {
            _sevenTVChannel?.sink.close(1000);
          }

          getAssets().then((_) {
            if (settings.show7TVEmotes) {
              final emoteSetId = assetsStore.sevenTvEmoteSetId;
              if (emoteSetId != null) {
                listenToSevenTVEmoteSet(emoteSetId: emoteSetId);
              }
            }
          });
        },
      ),
    );

    assetsStore.init();

    _messages.add(IRCMessage.createNotice(message: 'Connecting to chat...'));

    if (settings.showVideo && settings.chatDelay > 0) {
      _messages.add(
        IRCMessage.createNotice(
          message:
              'Waiting ${settings.chatDelay.toInt()} ${settings.chatDelay == 1.0 ? 'second' : 'seconds'} due to message delay setting...',
        ),
      );
    }

    reactions.add(
      reaction(
        (_) => settings.showVideo,
        (showVideo) {
          if (settings.chatDelay > 0) {
            if (showVideo) {
              _messages.add(
                IRCMessage.createNotice(
                  message:
                      'Waiting ${settings.chatDelay.toInt()} ${settings.chatDelay == 1.0 ? 'second' : 'seconds'} due to message delay setting...',
                ),
              );
            } else {
              _messages.add(
                IRCMessage.createNotice(
                  message: 'Removing message delay...',
                ),
              );
            }
          }
        },
      ),
    );

    if (settings.showRecentMessages) {
      getRecentMessage().then((_) => connectToChat());
    } else {
      connectToChat();
    }

    // Tell the scrollController to determine when auto-scroll should be enabled or disabled.
    scrollController.addListener(() {
      // If the scroll position is at the latest message (maximum possible), enable autoscroll.
      // Else if the position is before the latest message (not at the edge), disable autoscroll.
      if (scrollController.position.pixels <= 0) {
        _autoScroll = true;
      } else if (scrollController.position.pixels > 0) {
        _autoScroll = false;
      }
    });

    textFieldFocusNode.addListener(() {
      if (textFieldFocusNode.hasFocus) {
        // Hide the emote menu if it is currently shown.
        if (assetsStore.showEmoteMenu) assetsStore.showEmoteMenu = false;
      }

      // Un-expand the chat when unfocusing.
      if (!textFieldFocusNode.hasFocus) expandChat = false;
    });

    // Add a listener to the textfield that will show/hide the autocomplete bar if focused.
    // Will also rebuild the autocomplete bar when typing, refreshing the results as the user types.
    textController.addListener(() {
      _inputText = textController.text;

      _showEmoteAutocomplete = !_showMentionAutocomplete &&
          textFieldFocusNode.hasFocus &&
          textController.text.split(' ').last.isNotEmpty;

      _showSendButton = textController.text.isNotEmpty;
      _showMentionAutocomplete = textFieldFocusNode.hasFocus &&
          textController.text.split(' ').last.startsWith('@');
    });
  }

  /// Handle and process the provided string-representation of the IRC data.
  ///
  /// If a message, parses the IRC data into an [IRCMessage] and handles it based on the [Command].
  /// Else if a PING request, sends back the PONG to keep the connection alive.
  @action
  void _handleIRCData(String data) {
    // The IRC data can contain more than one message separated by CRLF.
    // To account for this, split by CRLF, then loop and process each message.
    for (final message in data.trimRight().split('\r\n')) {
      // debugPrint('$message\n');
      if (message.startsWith('@')) {
        final parsedIRCMessage =
            IRCMessage.fromString(message, userLogin: auth.user.details?.login);

        if (parsedIRCMessage.user != null) {
          chatDetailsStore.chatUsers.add(parsedIRCMessage.user!);
        }

        // Filter messages from any blocked users if not a moderator or not the channel owner.
        if (!_userState.mod &&
            channelName != auth.user.details?.login &&
            auth.user.blockedUsers
                .where(
                  (blockedUser) =>
                      blockedUser.userLogin == parsedIRCMessage.user,
                )
                .isNotEmpty) {
          continue;
        }

        // Filter messages containing any muted words.
        if (parsedIRCMessage.message != null) {
          final List<String> mutedWords = settings.mutedWords;

          // check if the message contains any of the muted words
          for (final word in mutedWords) {
            if (parsedIRCMessage.message!
                .toLowerCase()
                .split(settings.matchWholeWord ? ' ' : '')
                .contains(word.toLowerCase())) {
              return;
            }
          }
        }

        switch (parsedIRCMessage.command) {
          case Command.privateMessage:
          case Command.notice:
          case Command.userNotice:
            messageBuffer.add(parsedIRCMessage);
            break;
          case Command.clearChat:
            IRCMessage.clearChat(
              messages: _messages,
              bufferedMessages: messageBuffer,
              ircMessage: parsedIRCMessage,
            );
            break;
          case Command.clearMessage:
            IRCMessage.clearMessage(
              messages: _messages,
              bufferedMessages: messageBuffer,
              ircMessage: parsedIRCMessage,
            );
            break;
          case Command.roomState:
            chatDetailsStore.roomState =
                chatDetailsStore.roomState.fromIRCMessage(parsedIRCMessage);
            continue;
          case Command.userState:
            _userState = _userState.fromIRCMessage(parsedIRCMessage);

            if (toSend != null && parsedIRCMessage.tags['id'] != null) {
              toSend!.tags['id'] = parsedIRCMessage.tags['id']!;
              textController.clear();
              messageBuffer.add(toSend!);
              toSend = null;
            }
            break;
          case Command.globalUserState:
            final setIds = parsedIRCMessage.tags['emote-sets']?.split(',');
            if (setIds != null) {
              assetsStore.userEmotesFuture(
                emoteSets: setIds,
                headers: auth.headersTwitch,
                onError: (error) {
                  debugPrint(error.toString());
                  return <Emote>[];
                },
              );
            }
            continue;
          case Command.none:
            debugPrint('Unknown command: ${parsedIRCMessage.command}');
            continue;
        }

        if (!_autoScroll) {
          // While autoscroll is disabled, occasionally move messages from the buffer to the messages to prevent a memory leak.
          if (messageBuffer.length >= _messagesToRemove) {
            _messages.addAll(messageBuffer);
            messageBuffer.clear();
          }
        }

        // If the message limit is reached, remove the oldest messages.
        if (_messages.length >= _messageLimit) {
          _messages = _messages.sublist(_messagesToRemove).asObservable();
        }
      } else if (message == 'PING :tmi.twitch.tv') {
        _channel?.sink.add('PONG :tmi.twitch.tv');
        return;
      } else if (message.contains('Welcome, GLHF!')) {
        messageBuffer.add(
          IRCMessage.createNotice(
            message:
                "Welcome to ${getReadableName(displayName, channelName)}'s chat!",
          ),
        );

        // Activate the message buffer.
        // Create a timer that will add messages from the buffer every 200 milliseconds.
        _messageBufferTimer = Timer.periodic(
          const Duration(milliseconds: 200),
          (timer) => addMessages(),
        );

        getAssets().then((_) {
          if (!settings.show7TVEmotes) return;

          final emoteSetId = assetsStore.sevenTvEmoteSetId;
          if (emoteSetId != null && !_shouldDisconnect) {
            listenToSevenTVEmoteSet(emoteSetId: emoteSetId);
          }
        });

        // Reset exponential backoff if successfully connected.
        _retries = 0;
        _backoffTime = 0;
      }
    }
  }

  // Fetch the assets used in chat including badges and emotes.
  @action
  Future<void> getAssets() async => assetsStore.assetsFuture(
        channelId: channelId,
        headers: auth.headersTwitch,
        onEmoteError: (error) {
          debugPrint(error.toString());
          return <Emote>[];
        },
        onBadgeError: (error) {
          debugPrint(error.toString());
          return <ChatBadge>[];
        },
        showTwitchEmotes: settings.showTwitchEmotes,
        showTwitchBadges: settings.showTwitchBadges,
        show7TVEmotes: settings.show7TVEmotes,
        showBTTVEmotes: settings.showBTTVEmotes,
        showBTTVBadges: settings.showBTTVBadges,
        showFFZEmotes: settings.showFFZEmotes,
        showFFZBadges: settings.showFFZBadges,
      );

  /// Re-enables [_autoScroll] and jumps to the latest message.
  @action
  void resumeScroll() {
    _autoScroll = true;

    // Jump to the latest message (bottom of the list/chat).
    scrollController.jumpTo(0);

    // Add a post frame callback in the event a messages is added at the same time.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(0);
    });
  }

  @action
  void listenToSevenTVEmoteSet({required String emoteSetId}) {
    final subscribePayload = SevenTVEvent(
      op: 35,
      d: SevenTVEventData(
        type: 'emote_set.update',
        condition: {'object_id': emoteSetId},
      ),
    );

    _sevenTVChannel?.sink.close(1000);
    _sevenTVChannel =
        WebSocketChannel.connect(Uri.parse('wss://events.7tv.io/v3'));

    void listener(dynamic data) {
      // debugPrint(data);
      final decoded = jsonDecode(data);

      final event = SevenTVEvent.fromJson(decoded);

      final body = event.d.body;
      if (event.d.type != 'emote_set.update' || body == null) return;

      if (body.pushed != null) {
        final pushedEmote = body.pushed?.first.value;

        if (pushedEmote == null) return;

        final emote = Emote.from7TV(pushedEmote, EmoteType.sevenTVChannel);

        assetsStore.emoteToObject[emote.name] = emote;

        messageBuffer.add(
          IRCMessage.createNotice(
            message:
                '${getReadableName(body.actor.displayName, body.actor.username)} added 7TV emote "${emote.name}" to chat',
          ),
        );
      } else if (body.pulled != null) {
        final pulledEmote = body.pulled?.first.oldValue;

        if (pulledEmote == null) return;

        assetsStore.emoteToObject.removeWhere(
          (name, _) => name == pulledEmote.name,
        );

        messageBuffer.add(
          IRCMessage.createNotice(
            message:
                '${getReadableName(body.actor.displayName, body.actor.username)} removed 7TV emote "${pulledEmote.name}" from chat',
          ),
        );
      }
    }

    // Cancel previous subscription if exists
    _sevenTVChannelListener?.cancel();
    _sevenTVChannelListener = _sevenTVChannel?.stream.listen(
      (data) {
        if (!settings.showVideo || settings.chatDelay == 0) {
          listener(data);
        } else {
          Future.delayed(
            Duration(seconds: settings.chatDelay.toInt()),
            () => listener(data),
          );
        }
      },
      onError: (error) => debugPrint('7TV events error: ${error.toString()}'),
      onDone: () => debugPrint('7TV events done'),
    );

    _sevenTVChannel?.sink.add(jsonEncode(subscribePayload));
  }

  @action
  void connectToChat() {
    _channel?.sink.close(1000);
    _channel =
        WebSocketChannel.connect(Uri.parse('wss://irc-ws.chat.twitch.tv:443'));

    // Listen for new messages and forward them to the handler.
    _channelListener = _channel?.stream.listen(
      (data) {
        if (!settings.showVideo || settings.chatDelay == 0) {
          _handleIRCData(data.toString());
        } else {
          Future.delayed(
            Duration(seconds: settings.chatDelay.toInt()),
            () => _handleIRCData(data.toString()),
          );
        }
      },
      onError: (error) => debugPrint('Chat error: ${error.toString()}'),
      onDone: () async {
        if (_shouldDisconnect) {
          _sevenTVChannel?.sink.close(1000);
          return;
        }

        if (_retries >= _maxRetries) {
          messageBuffer.add(
            IRCMessage.createNotice(
              message: 'Disconnected from chat',
            ),
          );
          return;
        }

        if (_backoffTime > 0) {
          // Add notice that chat was disconnected and then wait the backoff time before reconnecting.
          final notice =
              'Disconnected from chat, waiting $_backoffTime ${_backoffTime == 1 ? 'second' : 'seconds'} before reconnecting...';
          messageBuffer.add(IRCMessage.createNotice(message: notice));
        }

        await Future.delayed(Duration(seconds: _backoffTime));

        // Increase the backoff time for the next retry.
        _backoffTime == 0 ? _backoffTime++ : _backoffTime *= 2;

        // Increment the retry count and attempt the reconnect.
        _retries++;
        messageBuffer.add(
          IRCMessage.createNotice(
            message: 'Reconnecting to chat (attempt $_retries)...',
          ),
        );
        _channelListener?.cancel();
        connectToChat();
      },
    );

    // The list of messages sent to the IRC WebSocket channel to connect and join.
    final commands = [
      // Request the tags and commands capabilities.
      // This will display tags containing metadata along with each IRC message.
      'CAP REQ :twitch.tv/tags twitch.tv/commands',

      // The OAuth token in order to connect, default or user token.
      'PASS oauth:${auth.token}',

      // The nickname for the connecting user. 'justinfan888' is the Twitch default if not logged in.
      'NICK ${auth.isLoggedIn ? auth.user.details!.login : 'justinfan888'}',

      // Join the desired channel's room.
      'JOIN #$channelName',
    ];

    // Send each command in order.
    for (final command in commands) {
      _channel?.sink.add(command);
    }
  }

  @action
  void addMessages() {
    if (!_autoScroll || messageBuffer.isEmpty) return;

    _messages.addAll(messageBuffer);
    messageBuffer.clear();
  }

  /// Sends the given string message by the logged-in user and adds it to [_messages].
  @action
  void sendMessage(String message) {
    // Do not send if the message is blank/empty.
    if (message.isEmpty) return;

    if (_channel == null || _channel?.closeCode != null) {
      messageBuffer.add(
        IRCMessage.createNotice(
          message: 'Failed to send message: disconnected from chat.',
        ),
      );
    } else {
      // Send the message to the IRC chat room.
      _channel?.sink.add(
        '${replyingToMessage != null ? '@reply-parent-msg-id=${replyingToMessage!.tags['id']} ' : ''}PRIVMSG #$channelName :$message',
      );

      // Obtain the logged-in user's appearance in chat with USERSTATE and create the full message to render.
      var userStateString = _userState.raw;
      if (userStateString != null) {
        if (message.length > 3 && message.substring(0, 3) == '/me') {
          userStateString +=
              ' :\x01ACTION ${message.replaceRange(0, 3, '').trim()}\x01';
        } else {
          userStateString +=
              ' :${replyingToMessage?.tags['display-name'] != null ? '@${replyingToMessage!.tags['display-name']} ' : ''}${message.trim()}';
        }

        final userChatMessage = IRCMessage.fromString(userStateString);
        userChatMessage.localEmotes?.addAll(assetsStore.userEmoteToObject);
        if (auth.isLoggedIn && auth.user.details != null) {
          userChatMessage.tags['user-id'] = auth.user.details!.id;
        }

        if (replyingToMessage != null &&
            replyingToMessage!.tags['id'] != null) {
          userChatMessage.tags['reply-parent-msg-id'] =
              replyingToMessage!.tags['id']!;
          userChatMessage.tags['reply-parent-display-name'] =
              replyingToMessage!.tags['display-name']!;
          userChatMessage.tags['reply-parent-msg-body'] =
              replyingToMessage!.message!;
        }

        replyingToMessage = null;
        toSend = userChatMessage;
      }
    }
  }

  /// Adds the given [emote] to the chat textfield.
  @action
  void addEmote(Emote emote, {bool autocompleteMode = false}) {
    if (textController.text.isEmpty || textController.text.endsWith(' ')) {
      textController.text += '${emote.name} ';
    } else if (autocompleteMode &&
        _showEmoteAutocomplete &&
        textController.text.endsWith('')) {
      final split = textController.text.split(' ')
        ..removeLast()
        ..add('${emote.name} ');

      textController.text = split.join(' ');
    } else {
      textController.text += ' ${emote.name} ';
    }

    assetsStore.recentEmotes
      ..removeWhere(
        (recentEmote) =>
            recentEmote.name == emote.name && recentEmote.type == emote.type,
      )
      ..insert(0, emote);

    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );
  }

  /// Cancels the previous notification/timer and creates a new one with the provided [notificationMessage].
  @action
  void updateNotification(String notificationMessage) {
    // Cancel the previous notification to prevent the notification from phasing in and out
    // when copying messages repeatedly.
    _notificationTimer?.cancel();

    // If empty, clear the notification and don't make a new timer (empty message means cancelling the notification).
    if (notificationMessage.isEmpty) {
      _notification = null;
      return;
    }

    // Set the new notification message and create a new timer that will dismiss it after 2 seconds.
    _notification = notificationMessage;
    _notificationTimer =
        Timer(const Duration(seconds: 3), () => _notification = null);
  }

  /// Updates the sleep timer with the given [duration].
  /// Calls [onTimerFinished] when the sleep timer completes.
  @action
  void updateSleepTimer({
    required Duration duration,
    required VoidCallback onTimerFinished,
  }) {
    // If there is an ongoing timer, cancel it since it'll be replaced.
    if (sleepTimer != null) cancelSleepTimer();

    // Update the new time remaining
    timeRemaining = duration;

    // Set a periodic timer that will update the time remaining every second.
    sleepTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        // If the timer is up, cancel the timer and exit the app.
        if (timeRemaining.inSeconds == 0) {
          timer.cancel();
          onTimerFinished();
          return;
        }

        // Decrement the time remaining.
        timeRemaining = Duration(seconds: timeRemaining.inSeconds - 1);
      },
    );
  }

  /// Cancels the sleep timer and resets the time remaining.
  @action
  void cancelSleepTimer() {
    sleepTimer?.cancel();
    timeRemaining = const Duration();
  }

  @action
  Future<void> getRecentMessage() async {
    final recentMessages =
        await twitchApi.getRecentMessages(userLogin: channelName);

    for (final message in recentMessages) {
      _handleIRCData(message);
    }
  }

  /// Closes and disposes all the channels and controllers used by the store.
  void dispose() {
    _shouldDisconnect = true;

    _messageBufferTimer?.cancel();
    _notificationTimer?.cancel();
    sleepTimer?.cancel();

    // Cancel WebSocket subscriptions
    _channelListener?.cancel();
    _sevenTVChannelListener?.cancel();

    // Close WebSocket channels
    _channel?.sink.close(1000);
    _sevenTVChannel?.sink.close(1000);

    for (final reactionDisposer in reactions) {
      reactionDisposer();
    }

    textFieldFocusNode.dispose();
    textController.dispose();
    scrollController.dispose();

    assetsStore.dispose();
    chatDetailsStore.dispose();

    // Disable wakelock so that the sleep timer will function properly.
    WakelockPlus.disable();
  }
}

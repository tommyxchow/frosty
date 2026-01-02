import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/irc.dart';

import '../fixtures/irc_messages.dart';

void main() {
  group('IRCMessage.fromString', () {
    group('basic parsing', () {
      test('parses basic chat message correctly', () {
        final msg = IRCMessage.fromString(basicPrivmsg);

        expect(msg.user, 'testuser');
        expect(msg.message, 'Hello World');
        expect(msg.command, Command.privateMessage);
        expect(msg.tags['display-name'], 'TestUser');
        expect(msg.tags['color'], '#FF0000');
        expect(msg.tags['user-id'], '67890');
        expect(msg.tags['room-id'], '12345');
      });

      test('parses message with escaped spaces in tags', () {
        final msg = IRCMessage.fromString(messageWithEscapedSpaces);

        // \\s should be converted to actual space
        expect(msg.tags['badge-info'], 'subscriber/12 months');
        expect(msg.message, 'test message');
      });

      test('handles message with no color tag', () {
        final msg = IRCMessage.fromString(messageNoColor);

        // Tags with empty values are skipped during parsing
        expect(msg.tags['color'], isNull);
        expect(msg.user, 'nocolor');
      });

      test('splits message into words correctly', () {
        final msg = IRCMessage.fromString(basicPrivmsg);

        expect(msg.split, ['Hello', 'World']);
      });
    });

    group('command detection', () {
      test('identifies PRIVMSG command', () {
        final msg = IRCMessage.fromString(basicPrivmsg);
        expect(msg.command, Command.privateMessage);
      });

      test('identifies CLEARCHAT command for user ban', () {
        final msg = IRCMessage.fromString(clearChatUser);
        expect(msg.command, Command.clearChat);
        expect(msg.message, 'banneduser');
        expect(msg.tags['ban-duration'], '600');
      });

      test('identifies CLEARCHAT command for full chat clear', () {
        final msg = IRCMessage.fromString(clearChatAll);
        expect(msg.command, Command.clearChat);
        expect(msg.message, isNull);
      });

      test('identifies CLEARMSG command', () {
        final msg = IRCMessage.fromString(clearMsg);
        expect(msg.command, Command.clearMessage);
        expect(msg.tags['target-msg-id'], 'target-msg-abc123');
      });

      test('identifies NOTICE command', () {
        final msg = IRCMessage.fromString(noticeMessage);
        expect(msg.command, Command.notice);
        expect(msg.tags['msg-id'], 'slow_on');
      });

      test('identifies USERNOTICE command', () {
        final msg = IRCMessage.fromString(userNoticeSubscription);
        expect(msg.command, Command.userNotice);
        expect(msg.tags['msg-id'], 'sub');
      });

      test('identifies ROOMSTATE command', () {
        final msg = IRCMessage.fromString(roomState);
        expect(msg.command, Command.roomState);
        expect(msg.tags['slow'], '0');
        expect(msg.tags['emote-only'], '0');
      });

      test('identifies USERSTATE command', () {
        final msg = IRCMessage.fromString(userState);
        expect(msg.command, Command.userState);
        expect(msg.tags['mod'], '0');
      });

      test('identifies GLOBALUSERSTATE command', () {
        final msg = IRCMessage.fromString(globalUserState);
        expect(msg.command, Command.globalUserState);
      });
    });

    group('emote parsing', () {
      test('extracts local emotes from emote tag', () {
        final msg = IRCMessage.fromString(privmsgWithEmotes);

        expect(msg.localEmotes, isNotNull);
        expect(msg.localEmotes!.containsKey('Kappa'), isTrue);
        expect(msg.localEmotes!.containsKey('LUL'), isTrue);

        // Verify emote URLs are constructed correctly
        expect(
          msg.localEmotes!['Kappa']!.url,
          contains('static-cdn.jtvnw.net/emoticons/v2/25'),
        );
      });

      test('handles multiple instances of same emote', () {
        final msg = IRCMessage.fromString(privmsgWithMultipleEmotes);

        // Should still only have one entry in localEmotes map
        expect(msg.localEmotes!.length, 1);
        expect(msg.localEmotes!['Kappa'], isNotNull);
      });

      test('handles message with no emotes', () {
        final msg = IRCMessage.fromString(basicPrivmsg);

        expect(msg.localEmotes, isEmpty);
      });
    });

    group('IRC action (/me) detection', () {
      test('detects /me action messages', () {
        final msg = IRCMessage.fromString(actionMessage);

        expect(msg.action, isTrue);
        expect(msg.message, 'is testing');
        // Action prefix and suffix should be stripped
        expect(msg.message, isNot(contains('\x01')));
      });

      test('non-action messages have action=false', () {
        final msg = IRCMessage.fromString(basicPrivmsg);
        expect(msg.action, isFalse);
      });
    });

    group('mention detection', () {
      test('detects when message mentions logged-in user', () {
        final msg = IRCMessage.fromString(
          mentionMessage,
          userLogin: 'targetuser',
        );

        expect(msg.mention, isTrue);
      });

      test('mention detection lowercases the message', () {
        // Note: The code lowercases the message but compares against userLogin as-is
        // So userLogin should be provided in lowercase for proper matching
        final msg = IRCMessage.fromString(
          mentionMessage,
          userLogin: 'targetuser', // lowercase to match the lowercased message
        );

        expect(msg.mention, isTrue);
      });

      test('no mention when user is not mentioned', () {
        final msg = IRCMessage.fromString(
          basicPrivmsg,
          userLogin: 'someotheruser',
        );

        expect(msg.mention, isFalse);
      });

      test('mention is null when userLogin not provided', () {
        final msg = IRCMessage.fromString(basicPrivmsg);
        expect(msg.mention, isFalse);
      });
    });

    group('Unicode handling', () {
      test('removes invalid Unicode characters', () {
        final msg = IRCMessage.fromString(messageWithInvalidUnicode);

        // The invalid Unicode character should be stripped
        expect(msg.message, 'HelloWorld');
        expect(msg.message, isNot(contains('\u{E0000}')));
      });

      test('handles emoji characters correctly', () {
        final msg = IRCMessage.fromString(messageWithEmoji);

        expect(msg.message, contains('😀'));
        expect(msg.message, contains('🎉'));
        // Emojis should be separated into their own entries in split
        expect(msg.split!.any((s) => s.contains('😀')), isTrue);
      });
    });

    group('reply message handling', () {
      test('parses reply message tags', () {
        final msg = IRCMessage.fromString(replyMessage);

        expect(msg.tags['reply-parent-display-name'], 'OriginalUser');
        expect(msg.tags['reply-parent-msg-id'], 'original-123');
        expect(msg.tags['reply-parent-user-login'], 'originaluser');
      });
    });

    group('special message types', () {
      test('parses moderator message', () {
        final msg = IRCMessage.fromString(moderatorMessage);

        expect(msg.tags['mod'], '1');
        expect(msg.tags['badges'], contains('moderator'));
      });

      test('parses historical message', () {
        final msg = IRCMessage.fromString(historicalMessage);

        expect(msg.tags['historical'], '1');
      });

      test('parses shared chat message with source room', () {
        final msg = IRCMessage.fromString(sharedChatMessage);

        expect(msg.tags['source-room-id'], '99999');
        expect(msg.tags['room-id'], '12345');
      });
    });
  });

  group('IRCMessage.clearChat', () {
    late List<IRCMessage> messages;
    late List<IRCMessage> bufferedMessages;

    setUp(() {
      // Create test messages from different users
      messages = [
        IRCMessage.fromString(basicPrivmsg), // from testuser
        IRCMessage.fromString(moderatorMessage), // from moduser
        IRCMessage.fromString(
          basicPrivmsg.replaceAll('testuser', 'user2').replaceAll('TestUser', 'User2'),
        ), // from user2
      ];
      bufferedMessages = [];
    });

    test('marks all messages from banned user', () {
      // Create a CLEARCHAT message targeting testuser
      final clearChatMsg = IRCMessage(
        raw: '',
        command: Command.clearChat,
        tags: {'ban-duration': '600'},
        message: 'testuser',
      );

      IRCMessage.clearChat(
        messages: messages,
        bufferedMessages: bufferedMessages,
        ircMessage: clearChatMsg,
      );

      // testuser's message should be marked as clearChat
      expect(
        messages.where((m) => m.user == 'testuser').first.command,
        Command.clearChat,
      );
      // Other users' messages should be unchanged
      expect(
        messages.where((m) => m.user == 'moduser').first.command,
        Command.privateMessage,
      );
    });

    test('adds ban-duration tag to affected messages', () {
      final clearChatMsg = IRCMessage(
        raw: '',
        command: Command.clearChat,
        tags: {'ban-duration': '300'},
        message: 'testuser',
      );

      IRCMessage.clearChat(
        messages: messages,
        bufferedMessages: bufferedMessages,
        ircMessage: clearChatMsg,
      );

      final affectedMessage = messages.where((m) => m.user == 'testuser').first;
      expect(affectedMessage.tags['ban-duration'], '300');
    });

    test('clears entire chat when no target user', () {
      final clearAllMsg = IRCMessage(
        raw: '',
        command: Command.clearChat,
        tags: {},
        message: null,
      );

      IRCMessage.clearChat(
        messages: messages,
        bufferedMessages: bufferedMessages,
        ircMessage: clearAllMsg,
      );

      // Messages list should be cleared and contain only the notice
      expect(messages.length, 1);
      expect(messages.first.command, Command.notice);
      expect(messages.first.message, 'Chat was cleared by a moderator');
    });
  });

  group('IRCMessage.clearMessage', () {
    late List<IRCMessage> messages;
    late List<IRCMessage> bufferedMessages;

    setUp(() {
      messages = [
        IRCMessage(
          raw: '',
          command: Command.privateMessage,
          tags: {'id': 'msg-1'},
          user: 'user1',
          message: 'Message 1',
        ),
        IRCMessage(
          raw: '',
          command: Command.privateMessage,
          tags: {'id': 'msg-2'},
          user: 'user2',
          message: 'Message 2',
        ),
        IRCMessage(
          raw: '',
          command: Command.privateMessage,
          tags: {'id': 'msg-3'},
          user: 'user1',
          message: 'Message 3',
        ),
      ];
      bufferedMessages = [];
    });

    test('marks specific message by ID', () {
      final clearMsg = IRCMessage(
        raw: '',
        command: Command.clearMessage,
        tags: {'target-msg-id': 'msg-2'},
      );

      IRCMessage.clearMessage(
        messages: messages,
        bufferedMessages: bufferedMessages,
        ircMessage: clearMsg,
      );

      // Only msg-2 should be marked
      expect(
        messages.firstWhere((m) => m.tags['id'] == 'msg-2').command,
        Command.clearMessage,
      );
      // Other messages unchanged
      expect(
        messages.firstWhere((m) => m.tags['id'] == 'msg-1').command,
        Command.privateMessage,
      );
      expect(
        messages.firstWhere((m) => m.tags['id'] == 'msg-3').command,
        Command.privateMessage,
      );
    });

    test('handles non-existent message ID gracefully', () {
      final clearMsg = IRCMessage(
        raw: '',
        command: Command.clearMessage,
        tags: {'target-msg-id': 'non-existent'},
      );

      // Should not throw
      expect(
        () => IRCMessage.clearMessage(
          messages: messages,
          bufferedMessages: bufferedMessages,
          ircMessage: clearMsg,
        ),
        returnsNormally,
      );

      // All messages should be unchanged
      expect(
        messages.every((m) => m.command == Command.privateMessage),
        isTrue,
      );
    });
  });

  group('IRCMessage.createNotice', () {
    test('creates notice message with correct properties', () {
      final notice = IRCMessage.createNotice(message: 'Test notice');

      expect(notice.command, Command.notice);
      expect(notice.message, 'Test notice');
      expect(notice.raw, isEmpty);
      expect(notice.tags, isEmpty);
    });

    test('creates notice with action callback', () {
      var called = false;
      final notice = IRCMessage.createNotice(
        message: 'Test',
        actionCallback: () => called = true,
        actionLabel: 'Retry',
      );

      expect(notice.actionCallback, isNotNull);
      expect(notice.actionLabel, 'Retry');
      notice.actionCallback!();
      expect(called, isTrue);
    });
  });

  group('ROOMSTATE', () {
    test('creates default ROOMSTATE', () {
      const roomstate = ROOMSTATE();

      expect(roomstate.emoteOnly, '0');
      expect(roomstate.followersOnly, '-1');
      expect(roomstate.r9k, '0');
      expect(roomstate.slowMode, '0');
      expect(roomstate.subMode, '0');
    });

    test('updates from IRC message', () {
      const original = ROOMSTATE();
      final ircMsg = IRCMessage(
        raw: '',
        command: Command.roomState,
        tags: {
          'emote-only': '1',
          'followers-only': '10',
          'slow': '30',
        },
      );

      final updated = original.fromIRCMessage(ircMsg);

      expect(updated.emoteOnly, '1');
      expect(updated.followersOnly, '10');
      expect(updated.slowMode, '30');
      // Unchanged values should keep original
      expect(updated.r9k, '0');
      expect(updated.subMode, '0');
    });
  });

  group('USERSTATE', () {
    test('creates default USERSTATE', () {
      const userstate = USERSTATE();

      expect(userstate.color, '');
      expect(userstate.displayName, '');
      expect(userstate.mod, isFalse);
      expect(userstate.subscriber, isFalse);
    });

    test('updates from IRC message', () {
      const original = USERSTATE();
      final ircMsg = IRCMessage(
        raw: '@color=#FF0000;display-name=TestUser;mod=1;subscriber=1',
        command: Command.userState,
        tags: {
          'color': '#FF0000',
          'display-name': 'TestUser',
          'mod': '1',
          'subscriber': '1',
        },
      );

      final updated = original.fromIRCMessage(ircMsg);

      expect(updated.color, '#FF0000');
      expect(updated.displayName, 'TestUser');
      expect(updated.mod, isTrue);
      expect(updated.subscriber, isTrue);
    });

    test('mod=0 is false', () {
      const original = USERSTATE();
      final ircMsg = IRCMessage(
        raw: '',
        command: Command.userState,
        tags: {'mod': '0'},
      );

      final updated = original.fromIRCMessage(ircMsg);
      expect(updated.mod, isFalse);
    });
  });
}

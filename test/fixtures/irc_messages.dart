/// Test fixtures containing real Twitch IRC message samples.
/// These are used to test the IRC message parsing logic.
library;

/// A basic chat message (PRIVMSG) with standard tags
const basicPrivmsg =
    '@badge-info=;badges=;color=#FF0000;display-name=TestUser;emotes=;'
    'id=abc123-def456;mod=0;room-id=12345;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=67890;user-type= '
    ':testuser!testuser@testuser.tmi.twitch.tv PRIVMSG #channel :Hello World';

/// A chat message with emotes in the tags
/// Note: emote positions are 0-indexed byte positions in the message
/// "Kappa LUL" - Kappa is at 0-4, LUL is at 6-8
const privmsgWithEmotes =
    '@badge-info=subscriber/12;badges=subscriber/12,premium/1;'
    'color=#1E90FF;display-name=EmoteUser;'
    'emotes=25:0-4/1902:6-8;id=msg-id-123;mod=0;room-id=12345;'
    'subscriber=1;tmi-sent-ts=1234567890123;turbo=0;user-id=11111;user-type= '
    ':emoteuser!emoteuser@emoteuser.tmi.twitch.tv PRIVMSG #channel :Kappa LUL';

/// A chat message with multiple instances of the same emote
const privmsgWithMultipleEmotes =
    '@badge-info=;badges=;color=#00FF00;display-name=MultiEmote;'
    'emotes=25:0-4,11-15;id=msg-456;mod=0;room-id=12345;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=22222;user-type= '
    ':multiemote!multiemote@multiemote.tmi.twitch.tv PRIVMSG #channel :Kappa test Kappa';

/// An IRC /me action message
const actionMessage =
    '@badge-info=;badges=broadcaster/1;color=#8A2BE2;display-name=Broadcaster;'
    'emotes=;id=action-123;mod=0;room-id=12345;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=12345;user-type= '
    ':broadcaster!broadcaster@broadcaster.tmi.twitch.tv PRIVMSG #channel '
    ':\x01ACTION is testing\x01';

/// A message that mentions another user
const mentionMessage =
    '@badge-info=;badges=;color=#FF6347;display-name=Mentioner;emotes=;'
    'id=mention-123;mod=0;room-id=12345;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=33333;user-type= '
    ':mentioner!mentioner@mentioner.tmi.twitch.tv PRIVMSG #channel :@targetuser hello!';

/// A message with escaped spaces in tags (\\s represents a space)
const messageWithEscapedSpaces =
    '@badge-info=subscriber/12\\smonths;badges=subscriber/12;color=#FF0000;'
    'display-name=EscapeTest;emotes=;id=escape-123;mod=0;room-id=12345;'
    'subscriber=1;tmi-sent-ts=1234567890123;turbo=0;user-id=44444;user-type= '
    ':escapetest!escapetest@escapetest.tmi.twitch.tv PRIVMSG #channel :test message';

/// A CLEARCHAT command that bans/times out a specific user
const clearChatUser =
    '@ban-duration=600;room-id=12345;target-user-id=67890;tmi-sent-ts=1234567890123 '
    ':tmi.twitch.tv CLEARCHAT #channel :banneduser';

/// A CLEARCHAT command that clears the entire chat (no target user)
const clearChatAll =
    '@room-id=12345;tmi-sent-ts=1234567890123 '
    ':tmi.twitch.tv CLEARCHAT #channel';

/// A CLEARMSG command that deletes a specific message
const clearMsg =
    '@login=deleteduser;room-id=;target-msg-id=target-msg-abc123;'
    'tmi-sent-ts=1234567890123 '
    ':tmi.twitch.tv CLEARMSG #channel :deleted message content';

/// A NOTICE command (system message)
const noticeMessage =
    '@msg-id=slow_on;room-id=12345 '
    ':tmi.twitch.tv NOTICE #channel :This room is now in slow mode.';

/// A USERNOTICE command (subscription, raid, etc.)
const userNoticeSubscription =
    '@badge-info=subscriber/1;badges=subscriber/0;color=#FF69B4;'
    'display-name=NewSub;emotes=;id=sub-123;login=newsub;mod=0;'
    'msg-id=sub;msg-param-cumulative-months=1;msg-param-months=0;'
    'msg-param-multimonth-duration=0;msg-param-multimonth-tenure=0;'
    'msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\\sSub;'
    'msg-param-sub-plan=1000;msg-param-was-gifted=false;room-id=12345;'
    'subscriber=1;system-msg=NewSub\\ssubscribed\\sat\\sTier\\s1.;'
    'tmi-sent-ts=1234567890123;user-id=55555;user-type= '
    ':tmi.twitch.tv USERNOTICE #channel';

/// A ROOMSTATE command with room settings
const roomState =
    '@emote-only=0;followers-only=-1;r9k=0;room-id=12345;slow=0;subs-only=0 '
    ':tmi.twitch.tv ROOMSTATE #channel';

/// A USERSTATE command with user state info
const userState =
    '@badge-info=;badges=broadcaster/1;color=#FF0000;display-name=Broadcaster;'
    'emote-sets=0,300374282;mod=0;subscriber=0;user-type= '
    ':tmi.twitch.tv USERSTATE #channel';

/// A GLOBALUSERSTATE command
const globalUserState =
    '@badge-info=;badges=premium/1;color=#8A2BE2;display-name=GlobalUser;'
    'emote-sets=0,300374282;user-id=12345;user-type= '
    ':tmi.twitch.tv GLOBALUSERSTATE';

/// A message with Unicode that should be filtered (invalid Unicode char)
const messageWithInvalidUnicode =
    '@badge-info=;badges=;color=#00FF00;display-name=UnicodeTest;emotes=;'
    'id=unicode-123;mod=0;room-id=12345;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=66666;user-type= '
    ':unicodetest!unicodetest@unicodetest.tmi.twitch.tv PRIVMSG #channel '
    ':Hello\u{E0000}World';

/// A message that is a reply to another message
const replyMessage =
    '@badge-info=;badges=;color=#FF4500;display-name=Replier;emotes=;'
    'id=reply-123;mod=0;reply-parent-display-name=OriginalUser;'
    'reply-parent-msg-body=original\\smessage;reply-parent-msg-id=original-123;'
    'reply-parent-user-id=77777;reply-parent-user-login=originaluser;'
    'room-id=12345;subscriber=0;tmi-sent-ts=1234567890123;'
    'turbo=0;user-id=88888;user-type= '
    ':replier!replier@replier.tmi.twitch.tv PRIVMSG #channel :@OriginalUser this is my reply';

/// A message from a moderator
const moderatorMessage =
    '@badge-info=subscriber/24;badges=moderator/1,subscriber/24;'
    'color=#2E8B57;display-name=ModUser;emotes=;id=mod-123;mod=1;'
    'room-id=12345;subscriber=1;tmi-sent-ts=1234567890123;'
    'turbo=0;user-id=99999;user-type=mod '
    ':moduser!moduser@moduser.tmi.twitch.tv PRIVMSG #channel :Mod message here';

/// A message with no color set (should default to grey)
const messageNoColor =
    '@badge-info=;badges=;color=;display-name=NoColor;emotes=;'
    'id=nocolor-123;mod=0;room-id=12345;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=11111;user-type= '
    ':nocolor!nocolor@nocolor.tmi.twitch.tv PRIVMSG #channel :No color message';

/// A historical message (from recent messages API)
const historicalMessage =
    '@badge-info=;badges=;color=#FF0000;display-name=HistUser;emotes=;'
    'historical=1;id=hist-123;mod=0;room-id=12345;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=12121;user-type= '
    ':histuser!histuser@histuser.tmi.twitch.tv PRIVMSG #channel :Historical message';

/// A message from a shared chat session (source room different from current)
const sharedChatMessage =
    '@badge-info=;badges=;color=#00BFFF;display-name=SharedUser;emotes=;'
    'id=shared-123;mod=0;room-id=12345;source-room-id=99999;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=13131;user-type= '
    ':shareduser!shareduser@shareduser.tmi.twitch.tv PRIVMSG #channel :From another channel';

/// A message with emoji characters
const messageWithEmoji =
    '@badge-info=;badges=;color=#FFD700;display-name=EmojiUser;emotes=;'
    'id=emoji-123;mod=0;room-id=12345;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=14141;user-type= '
    ':emojiuser!emojiuser@emojiuser.tmi.twitch.tv PRIVMSG #channel :Hello 😀🎉 World';

/// A message with a URL
const messageWithUrl =
    '@badge-info=;badges=;color=#9400D3;display-name=LinkUser;emotes=;'
    'id=url-123;mod=0;room-id=12345;subscriber=0;'
    'tmi-sent-ts=1234567890123;turbo=0;user-id=15151;user-type= '
    ':linkuser!linkuser@linkuser.tmi.twitch.tv PRIVMSG #channel :Check out https://twitch.tv/channel';

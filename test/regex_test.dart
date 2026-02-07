import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/irc.dart';

void main() {
  group('regexLink', () {
    group('URL matching', () {
      test('matches HTTPS URLs', () {
        expect(regexLink.hasMatch('https://twitch.tv'), isTrue);
        expect(regexLink.hasMatch('https://www.twitch.tv'), isTrue);
        expect(regexLink.hasMatch('https://example.com/path'), isTrue);
        expect(regexLink.hasMatch('https://sub.domain.com'), isTrue);
      });

      test('matches HTTP URLs', () {
        expect(regexLink.hasMatch('http://example.com'), isTrue);
        expect(regexLink.hasMatch('http://www.example.com'), isTrue);
      });

      test('matches URLs without protocol', () {
        expect(regexLink.hasMatch('twitch.tv'), isTrue);
        expect(regexLink.hasMatch('www.twitch.tv'), isTrue);
        expect(regexLink.hasMatch('example.com'), isTrue);
      });

      test('matches URLs with paths', () {
        expect(regexLink.hasMatch('twitch.tv/channel'), isTrue);
        expect(regexLink.hasMatch('example.com/path/to/page'), isTrue);
        expect(regexLink.hasMatch('github.com/user/repo'), isTrue);
      });

      test('matches URLs with query strings', () {
        expect(regexLink.hasMatch('example.com?query=value'), isTrue);
        expect(regexLink.hasMatch('example.com/path?foo=bar&baz=qux'), isTrue);
      });

      test('matches URLs with ports', () {
        // Note: localhost without a TLD doesn't match (requires domain.tld format)
        expect(regexLink.hasMatch('localhost:3000'), isFalse);
        expect(regexLink.hasMatch('example.com:8080/path'), isTrue);
        expect(regexLink.hasMatch('sub.example.com:8080'), isTrue);
      });

      test('matches URLs with hash fragments', () {
        expect(regexLink.hasMatch('example.com#section'), isTrue);
        expect(regexLink.hasMatch('example.com/page#anchor'), isTrue);
      });

      test('matches various TLDs', () {
        expect(regexLink.hasMatch('example.co'), isTrue);
        expect(regexLink.hasMatch('example.io'), isTrue);
        expect(regexLink.hasMatch('example.dev'), isTrue);
        expect(regexLink.hasMatch('example.org'), isTrue);
        expect(regexLink.hasMatch('example.net'), isTrue);
      });

      test('matches international TLDs', () {
        expect(regexLink.hasMatch('example.co.uk'), isTrue);
        expect(regexLink.hasMatch('example.com.br'), isTrue);
      });
    });

    group('file name matching', () {
      test('matches common image files', () {
        expect(regexLink.hasMatch('image.png'), isTrue);
        expect(regexLink.hasMatch('photo.jpg'), isTrue);
        expect(regexLink.hasMatch('photo.jpeg'), isTrue);
        expect(regexLink.hasMatch('animation.gif'), isTrue);
        expect(regexLink.hasMatch('bitmap.bmp'), isTrue);
        expect(regexLink.hasMatch('modern.webp'), isTrue);
      });

      test('matches video and archive files', () {
        expect(regexLink.hasMatch('video.mp4'), isTrue);
        expect(regexLink.hasMatch('movie.avi'), isTrue);
        expect(regexLink.hasMatch('archive.zip'), isTrue);
        expect(regexLink.hasMatch('archive.rar'), isTrue);
      });

      test('matches document and executable files', () {
        expect(regexLink.hasMatch('document.pdf'), isTrue);
        expect(regexLink.hasMatch('program.exe'), isTrue);
      });

      test('handles filenames with underscores and hyphens', () {
        expect(regexLink.hasMatch('my_image.png'), isTrue);
        expect(regexLink.hasMatch('my-image.png'), isTrue);
        expect(regexLink.hasMatch('my_cool-image_v2.jpg'), isTrue);
      });
    });

    group('non-matching cases', () {
      test('does not match plain text', () {
        expect(regexLink.hasMatch('hello world'), isFalse);
        expect(regexLink.hasMatch('just some text'), isFalse);
      });

      test('does not match words ending with common extensions', () {
        // These should NOT match as they're not file patterns
        expect(regexLink.hasMatch('testing'), isFalse);
        expect(regexLink.hasMatch('running'), isFalse);
      });

      test('does not match single words without TLD', () {
        expect(regexLink.hasMatch('example'), isFalse);
        expect(regexLink.hasMatch('localhost'), isFalse);
      });

      test('matches domain part of email addresses', () {
        // The regex matches the domain portion (example.com) within an email
        // This is expected behavior — the regex is for URLs, not email filtering
        expect(regexLink.hasMatch('user@example.com'), isTrue);
      });
    });

    group('boundary handling', () {
      test('matches URLs in sentences', () {
        final text = 'Check out twitch.tv/channel for more';
        expect(regexLink.hasMatch(text), isTrue);

        final match = regexLink.firstMatch(text);
        expect(match?.group(0), 'twitch.tv/channel');
      });

      test('handles URLs at start of string', () {
        final match = regexLink.firstMatch('example.com is a website');
        expect(match?.group(0), 'example.com');
      });

      test('handles URLs at end of string', () {
        final match = regexLink.firstMatch('Visit example.com');
        expect(match?.group(0), 'example.com');
      });
    });
  });

  group('regexEmoji', () {
    group('matching emojis', () {
      test('matches basic smileys', () {
        expect(regexEmoji.hasMatch('😀'), isTrue);
        expect(regexEmoji.hasMatch('😃'), isTrue);
        expect(regexEmoji.hasMatch('😄'), isTrue);
        expect(regexEmoji.hasMatch('🙂'), isTrue);
        expect(regexEmoji.hasMatch('😊'), isTrue);
      });

      test('matches celebration emojis', () {
        expect(regexEmoji.hasMatch('🎉'), isTrue);
        expect(regexEmoji.hasMatch('🎊'), isTrue);
        expect(regexEmoji.hasMatch('🎁'), isTrue);
      });

      test('matches hand gestures', () {
        expect(regexEmoji.hasMatch('👍'), isTrue);
        expect(regexEmoji.hasMatch('👎'), isTrue);
        expect(regexEmoji.hasMatch('👏'), isTrue);
        expect(regexEmoji.hasMatch('🙌'), isTrue);
      });

      test('matches heart emojis', () {
        expect(regexEmoji.hasMatch('❤️'), isTrue);
        expect(regexEmoji.hasMatch('💙'), isTrue);
        expect(regexEmoji.hasMatch('💚'), isTrue);
        expect(regexEmoji.hasMatch('💛'), isTrue);
      });

      test('matches nature emojis', () {
        expect(regexEmoji.hasMatch('🌟'), isTrue);
        expect(regexEmoji.hasMatch('⭐'), isTrue);
        expect(regexEmoji.hasMatch('🌈'), isTrue);
        expect(regexEmoji.hasMatch('☀️'), isTrue);
      });

      test('matches flag emojis', () {
        expect(regexEmoji.hasMatch('🇺🇸'), isTrue);
        expect(regexEmoji.hasMatch('🇬🇧'), isTrue);
        expect(regexEmoji.hasMatch('🇯🇵'), isTrue);
      });

      test('matches symbol emojis', () {
        expect(regexEmoji.hasMatch('✅'), isTrue);
        expect(regexEmoji.hasMatch('❌'), isTrue);
        expect(regexEmoji.hasMatch('⚠️'), isTrue);
      });
    });

    group('non-matching cases', () {
      test('does not match regular ASCII text', () {
        expect(regexEmoji.hasMatch('hello'), isFalse);
        expect(regexEmoji.hasMatch('world'), isFalse);
        expect(regexEmoji.hasMatch('test123'), isFalse);
      });

      test('does not match numbers', () {
        expect(regexEmoji.hasMatch('123'), isFalse);
        expect(regexEmoji.hasMatch('456789'), isFalse);
      });

      test('does not match punctuation', () {
        expect(regexEmoji.hasMatch('!@#'), isFalse);
        expect(regexEmoji.hasMatch('...'), isFalse);
        expect(regexEmoji.hasMatch('???'), isFalse);
      });

      test('does not match basic ASCII symbols', () {
        expect(regexEmoji.hasMatch(':)'), isFalse);
        expect(regexEmoji.hasMatch(':('), isFalse);
        expect(regexEmoji.hasMatch(':D'), isFalse);
      });
    });

    group('extracting emojis from text', () {
      test('extracts emoji from mixed text', () {
        const text = 'Hello 😀 World';
        final matches = regexEmoji.allMatches(text);
        expect(matches.length, 1);
        expect(matches.first.group(0), '😀');
      });

      test('extracts multiple emojis', () {
        const text = '🎉 Party 🎊 Time 🎁';
        final matches = regexEmoji.allMatches(text);
        expect(matches.length, 3);
      });

      test('handles consecutive emojis', () {
        const text = '😀😃😄';
        final matches = regexEmoji.allMatches(text);
        // Consecutive emojis may be grouped into a single match by the regex
        expect(matches.length, greaterThanOrEqualTo(1));
        // Verify all emoji characters are captured
        final matched = matches.map((m) => m.group(0)).join();
        expect(matched, text);
      });
    });
  });

  group('regexEnglish', () {
    test('matches strings with lowercase letters', () {
      expect(regexEnglish.hasMatch('hello'), isTrue);
      expect(regexEnglish.hasMatch('abc'), isTrue);
    });

    test('matches strings with uppercase letters', () {
      expect(regexEnglish.hasMatch('HELLO'), isTrue);
      expect(regexEnglish.hasMatch('ABC'), isTrue);
    });

    test('matches mixed case', () {
      expect(regexEnglish.hasMatch('HeLLo'), isTrue);
    });

    test('matches strings containing English letters', () {
      expect(regexEnglish.hasMatch('テストTest'), isTrue);
      expect(regexEnglish.hasMatch('123abc456'), isTrue);
    });

    test('does not match pure numbers', () {
      expect(regexEnglish.hasMatch('12345'), isFalse);
    });

    test('does not match non-English alphabets only', () {
      expect(regexEnglish.hasMatch('テスト'), isFalse);
      expect(regexEnglish.hasMatch('测试'), isFalse);
      expect(regexEnglish.hasMatch('тест'), isFalse);
    });

    test('does not match symbols only', () {
      expect(regexEnglish.hasMatch(r'!@#$%'), isFalse);
      expect(regexEnglish.hasMatch('_-+='), isFalse);
    });
  });

  group('regexNumbersOnly', () {
    test('matches numeric-only strings', () {
      expect(regexNumbersOnly.hasMatch('123'), isTrue);
      expect(regexNumbersOnly.hasMatch('0'), isTrue);
      expect(regexNumbersOnly.hasMatch('999999'), isTrue);
    });

    test('does not match strings with letters', () {
      expect(regexNumbersOnly.hasMatch('123abc'), isFalse);
      expect(regexNumbersOnly.hasMatch('abc123'), isFalse);
      expect(regexNumbersOnly.hasMatch('12a34'), isFalse);
    });

    test('does not match strings with symbols', () {
      expect(regexNumbersOnly.hasMatch('12.34'), isFalse);
      expect(regexNumbersOnly.hasMatch('12-34'), isFalse);
      expect(regexNumbersOnly.hasMatch('12_34'), isFalse);
    });

    test('does not match empty string', () {
      expect(regexNumbersOnly.hasMatch(''), isFalse);
    });

    test('does not match strings with spaces', () {
      expect(regexNumbersOnly.hasMatch('123 456'), isFalse);
      expect(regexNumbersOnly.hasMatch(' 123'), isFalse);
    });
  });

  group('zeroWidthEmotes constant', () {
    test('contains all expected zero-width BTTV emotes', () {
      expect(zeroWidthEmotes, contains('SoSnowy'));
      expect(zeroWidthEmotes, contains('IceCold'));
      expect(zeroWidthEmotes, contains('SantaHat'));
      expect(zeroWidthEmotes, contains('TopHat'));
      expect(zeroWidthEmotes, contains('ReinDeer'));
      expect(zeroWidthEmotes, contains('CandyCane'));
      expect(zeroWidthEmotes, contains('cvMask'));
      expect(zeroWidthEmotes, contains('cvHazmat'));
    });

    test('has expected count', () {
      expect(zeroWidthEmotes.length, 8);
    });
  });

  group('chatColorNames and chatColorValues', () {
    test('all color names have corresponding values', () {
      for (final name in chatColorNames) {
        expect(chatColorValues.containsKey(name), isTrue,
            reason: '$name should have a color value');
      }
    });

    test('contains expected colors', () {
      expect(chatColorNames, contains('blue'));
      expect(chatColorNames, contains('red'));
      expect(chatColorNames, contains('green'));
      expect(chatColorNames, contains('hot_pink'));
      expect(chatColorNames, contains('golden_rod'));
    });

    test('color values are non-null', () {
      for (final entry in chatColorValues.entries) {
        expect(entry.value, isNotNull,
            reason: '${entry.key} should have a valid color');
      }
    });
  });
}

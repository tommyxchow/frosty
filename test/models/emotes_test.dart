import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/emotes.dart';

void main() {
  group('Emote.fromTwitch', () {
    test('creates emote with default and static URLs', () {
      final twitchEmote = EmoteTwitch('25', 'Kappa', 'bitstier', null);

      final emote = Emote.fromTwitch(twitchEmote, EmoteType.twitchGlobal);

      expect(
        emote.url,
        'https://static-cdn.jtvnw.net/emoticons/v2/25/default/dark/3.0',
      );
      expect(
        emote.staticUrl,
        'https://static-cdn.jtvnw.net/emoticons/v2/25/static/dark/3.0',
      );
      expect(emote.name, 'Kappa');
      expect(emote.type, EmoteType.twitchGlobal);
      expect(emote.zeroWidth, isFalse);
    });

    test('preserves owner ID when provided', () {
      final twitchEmote = EmoteTwitch('12345', 'SubEmote', 'subscriptions', '67890');

      final emote = Emote.fromTwitch(twitchEmote, EmoteType.twitchSub);

      expect(emote.ownerId, '67890');
    });
  });

  group('Emote.fromBTTV', () {
    test('creates emote with correct URL', () {
      final bttvEmote = EmoteBTTV('abc123', 'PogChamp');

      final emote = Emote.fromBTTV(bttvEmote, EmoteType.bttvGlobal);

      expect(emote.url, 'https://cdn.betterttv.net/emote/abc123/3x');
      expect(emote.name, 'PogChamp');
      expect(emote.type, EmoteType.bttvGlobal);
    });

    test('marks SoSnowy as zero-width', () {
      final bttvEmote = EmoteBTTV('snowyid', 'SoSnowy');

      final emote = Emote.fromBTTV(bttvEmote, EmoteType.bttvGlobal);

      expect(emote.zeroWidth, isTrue);
    });

    test('marks IceCold as zero-width', () {
      final bttvEmote = EmoteBTTV('iceid', 'IceCold');

      final emote = Emote.fromBTTV(bttvEmote, EmoteType.bttvChannel);

      expect(emote.zeroWidth, isTrue);
    });

    test('marks SantaHat as zero-width', () {
      final bttvEmote = EmoteBTTV('santaid', 'SantaHat');

      final emote = Emote.fromBTTV(bttvEmote, EmoteType.bttvShared);

      expect(emote.zeroWidth, isTrue);
    });

    test('marks TopHat as zero-width', () {
      final bttvEmote = EmoteBTTV('topid', 'TopHat');

      final emote = Emote.fromBTTV(bttvEmote, EmoteType.bttvGlobal);

      expect(emote.zeroWidth, isTrue);
    });

    test('marks cvMask as zero-width', () {
      final bttvEmote = EmoteBTTV('maskid', 'cvMask');

      final emote = Emote.fromBTTV(bttvEmote, EmoteType.bttvGlobal);

      expect(emote.zeroWidth, isTrue);
    });

    test('marks cvHazmat as zero-width', () {
      final bttvEmote = EmoteBTTV('hazmatid', 'cvHazmat');

      final emote = Emote.fromBTTV(bttvEmote, EmoteType.bttvGlobal);

      expect(emote.zeroWidth, isTrue);
    });

    test('regular emotes are not zero-width', () {
      final bttvEmote = EmoteBTTV('regularid', 'RegularEmote');

      final emote = Emote.fromBTTV(bttvEmote, EmoteType.bttvGlobal);

      expect(emote.zeroWidth, isFalse);
    });
  });

  group('Emote.fromFFZ', () {
    test('creates emote with static URL when no animation', () {
      final ffzEmote = EmoteFFZ(
        'TestFFZ',
        28,
        28,
        const OwnerFFZ(displayName: 'Owner', name: 'owner'),
        const ImagesFFZ(
          'https://cdn.ffz.net/1x.png',
          'https://cdn.ffz.net/2x.png',
          'https://cdn.ffz.net/4x.png',
        ),
        null, // No animation
      );

      final emote = Emote.fromFFZ(ffzEmote, EmoteType.ffzChannel);

      expect(emote.url, 'https://cdn.ffz.net/4x.png');
      expect(emote.name, 'TestFFZ');
      expect(emote.type, EmoteType.ffzChannel);
      expect(emote.width, 28);
      expect(emote.height, 28);
      expect(emote.ownerDisplayName, 'Owner');
      expect(emote.ownerUsername, 'owner');
    });

    test('prefers animated URL when available', () {
      final ffzEmote = EmoteFFZ(
        'AnimatedFFZ',
        32,
        32,
        const OwnerFFZ(displayName: 'AnimOwner', name: 'animowner'),
        const ImagesFFZ(
          'https://cdn.ffz.net/static/1x.png',
          'https://cdn.ffz.net/static/2x.png',
          'https://cdn.ffz.net/static/4x.png',
        ),
        const ImagesFFZ(
          'https://cdn.ffz.net/anim/1x.gif',
          'https://cdn.ffz.net/anim/2x.gif',
          'https://cdn.ffz.net/anim/4x.gif',
        ),
      );

      final emote = Emote.fromFFZ(ffzEmote, EmoteType.ffzGlobal);

      expect(emote.url, 'https://cdn.ffz.net/anim/4x.gif');
    });

    test('falls back to 2x then 1x when 4x not available', () {
      final ffzEmote = EmoteFFZ(
        'NoFourX',
        20,
        20,
        const OwnerFFZ(displayName: 'Owner', name: 'owner'),
        const ImagesFFZ(
          'https://cdn.ffz.net/1x.png',
          'https://cdn.ffz.net/2x.png',
          null, // No 4x
        ),
        null,
      );

      final emote = Emote.fromFFZ(ffzEmote, EmoteType.ffzChannel);

      expect(emote.url, 'https://cdn.ffz.net/2x.png');
    });

    test('falls back to 1x when only 1x available', () {
      final ffzEmote = EmoteFFZ(
        'OnlyOneX',
        18,
        18,
        const OwnerFFZ(displayName: 'Owner', name: 'owner'),
        const ImagesFFZ(
          'https://cdn.ffz.net/1x.png',
          null, // No 2x
          null, // No 4x
        ),
        null,
      );

      final emote = Emote.fromFFZ(ffzEmote, EmoteType.ffzChannel);

      expect(emote.url, 'https://cdn.ffz.net/1x.png');
    });

    test('prefers animated fallback chain over static', () {
      final ffzEmote = EmoteFFZ(
        'AnimFallback',
        24,
        24,
        const OwnerFFZ(displayName: 'Owner', name: 'owner'),
        const ImagesFFZ(
          'https://cdn.ffz.net/static/1x.png',
          'https://cdn.ffz.net/static/2x.png',
          'https://cdn.ffz.net/static/4x.png',
        ),
        const ImagesFFZ(
          'https://cdn.ffz.net/anim/1x.gif',
          'https://cdn.ffz.net/anim/2x.gif',
          null, // No animated 4x
        ),
      );

      final emote = Emote.fromFFZ(ffzEmote, EmoteType.ffzGlobal);

      // Should use animated 2x since animated 4x is not available
      expect(emote.url, 'https://cdn.ffz.net/anim/2x.gif');
    });
  });

  group('Emote.from7TV', () {
    test('creates emote with WEBP URL (filters AVIF)', () {
      final emote7TV = Emote7TV(
        '7tvid123',
        'TestEmote',
        Emote7TVData(
          '7tvid123',
          'TestEmote',
          0, // No flags
          const Owner7TV(username: 'owner', displayName: 'Owner'),
          Emote7TVHost(
            '//cdn.7tv.app/emote/7tvid123',
            [
              Emote7TVFile('1x.webp', '1x_static.webp', 32, 32, 'WEBP'),
              Emote7TVFile('2x.webp', '2x_static.webp', 64, 64, 'WEBP'),
              Emote7TVFile('3x.webp', '3x_static.webp', 96, 96, 'WEBP'),
              Emote7TVFile('4x.webp', '4x_static.webp', 128, 128, 'WEBP'),
              Emote7TVFile('1x.avif', '1x_static.avif', 32, 32, 'AVIF'),
              Emote7TVFile('2x.avif', '2x_static.avif', 64, 64, 'AVIF'),
              Emote7TVFile('3x.avif', '3x_static.avif', 96, 96, 'AVIF'),
              Emote7TVFile('4x.avif', '4x_static.avif', 128, 128, 'AVIF'),
            ],
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVChannel);

      // Should use WEBP, not AVIF
      expect(emote.url, contains('webp'));
      expect(emote.url, isNot(contains('avif')));
      expect(emote.url, 'https://cdn.7tv.app/emote/7tvid123/4x.webp');
    });

    test('detects zero-width from flag bit 8 (256)', () {
      final emote7TV = Emote7TV(
        'zw123',
        'ZeroWidth',
        Emote7TVData(
          'zw123',
          'ZeroWidth',
          256, // Bit 8 set = zero-width
          null,
          Emote7TVHost(
            '//cdn.7tv.app/emote/zw123',
            [Emote7TVFile('1x.webp', '1x_static.webp', 32, 32, 'WEBP')],
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVGlobal);

      expect(emote.zeroWidth, isTrue);
    });

    test('non-zero-width when flag bit 8 not set', () {
      final emote7TV = Emote7TV(
        'regular123',
        'RegularEmote',
        Emote7TVData(
          'regular123',
          'RegularEmote',
          128, // Different flag, not 256
          null,
          Emote7TVHost(
            '//cdn.7tv.app/emote/regular123',
            [Emote7TVFile('1x.webp', '1x_static.webp', 32, 32, 'WEBP')],
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVChannel);

      expect(emote.zeroWidth, isFalse);
    });

    test('sets realName when different from emote name', () {
      final emote7TV = Emote7TV(
        'alias123',
        'AliasName', // The alias used in channel
        Emote7TVData(
          'alias123',
          'OriginalName', // The original name
          0,
          null,
          Emote7TVHost(
            '//cdn.7tv.app/emote/alias123',
            [Emote7TVFile('1x.webp', '1x_static.webp', 32, 32, 'WEBP')],
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVChannel);

      expect(emote.name, 'AliasName');
      expect(emote.realName, 'OriginalName');
    });

    test('realName is null when name matches', () {
      final emote7TV = Emote7TV(
        'same123',
        'SameName',
        Emote7TVData(
          'same123',
          'SameName', // Same as emote.name
          0,
          null,
          Emote7TVHost(
            '//cdn.7tv.app/emote/same123',
            [Emote7TVFile('1x.webp', '1x_static.webp', 32, 32, 'WEBP')],
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVGlobal);

      expect(emote.name, 'SameName');
      expect(emote.realName, isNull);
    });

    test('extracts owner info when available', () {
      final emote7TV = Emote7TV(
        'owned123',
        'OwnedEmote',
        Emote7TVData(
          'owned123',
          'OwnedEmote',
          0,
          const Owner7TV(username: 'creator', displayName: 'EmoteCreator'),
          Emote7TVHost(
            '//cdn.7tv.app/emote/owned123',
            [Emote7TVFile('1x.webp', '1x_static.webp', 32, 32, 'WEBP')],
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVChannel);

      expect(emote.ownerUsername, 'creator');
      expect(emote.ownerDisplayName, 'EmoteCreator');
    });

    test('handles null owner', () {
      final emote7TV = Emote7TV(
        'noowner123',
        'NoOwner',
        Emote7TVData(
          'noowner123',
          'NoOwner',
          0,
          null, // No owner
          Emote7TVHost(
            '//cdn.7tv.app/emote/noowner123',
            [Emote7TVFile('1x.webp', '1x_static.webp', 32, 32, 'WEBP')],
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVGlobal);

      expect(emote.ownerUsername, isNull);
      expect(emote.ownerDisplayName, isNull);
    });

    test('uses first file dimensions', () {
      final emote7TV = Emote7TV(
        'dim123',
        'Dimensions',
        Emote7TVData(
          'dim123',
          'Dimensions',
          0,
          null,
          Emote7TVHost(
            '//cdn.7tv.app/emote/dim123',
            [
              Emote7TVFile('1x.webp', '1x_static.webp', 28, 32, 'WEBP'),
              Emote7TVFile('2x.webp', '2x_static.webp', 56, 64, 'WEBP'),
            ],
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVChannel);

      expect(emote.width, 28);
      expect(emote.height, 32);
    });

    test('handles empty file list', () {
      final emote7TV = Emote7TV(
        'empty123',
        'EmptyFiles',
        Emote7TVData(
          'empty123',
          'EmptyFiles',
          0,
          null,
          Emote7TVHost(
            '//cdn.7tv.app/emote/empty123',
            [], // No files
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVGlobal);

      // Should return empty URL when no files
      expect(emote.url, '');
      expect(emote.width, isNull);
      expect(emote.height, isNull);
    });

    test('filters AVIF-only files and returns empty URL', () {
      final emote7TV = Emote7TV(
        'avifonly123',
        'AvifOnly',
        Emote7TVData(
          'avifonly123',
          'AvifOnly',
          0,
          null,
          Emote7TVHost(
            '//cdn.7tv.app/emote/avifonly123',
            [
              Emote7TVFile('1x.avif', '1x_static.avif', 32, 32, 'AVIF'),
              Emote7TVFile('2x.avif', '2x_static.avif', 64, 64, 'AVIF'),
            ],
          ),
        ),
      );

      final emote = Emote.from7TV(emote7TV, EmoteType.sevenTVChannel);

      // All files are AVIF, so should return empty URL
      expect(emote.url, '');
    });
  });

  group('EmoteType', () {
    test('toString returns human-readable string', () {
      expect(EmoteType.twitchBits.toString(), 'Twitch bits emote');
      expect(EmoteType.twitchFollower.toString(), 'Twitch follower emote');
      expect(EmoteType.twitchSub.toString(), 'Twitch sub emote');
      expect(EmoteType.twitchGlobal.toString(), 'Twitch global emote');
      expect(EmoteType.twitchUnlocked.toString(), 'Twitch unlocked emote');
      expect(EmoteType.twitchChannel.toString(), 'Twitch channel emote');
      expect(EmoteType.ffzGlobal.toString(), 'FrankerFaceZ global emote');
      expect(EmoteType.ffzChannel.toString(), 'FrankerFaceZ channel emote');
      expect(EmoteType.bttvGlobal.toString(), 'BetterTTV global emote');
      expect(EmoteType.bttvChannel.toString(), 'BetterTTV channel emote');
      expect(EmoteType.bttvShared.toString(), 'BetterTTV shared emote');
      expect(EmoteType.sevenTVGlobal.toString(), '7TV global emote');
      expect(EmoteType.sevenTVChannel.toString(), '7TV channel emote');
    });
  });

  group('Emote JSON serialization', () {
    test('roundtrip serialization works', () {
      const original = Emote(
        name: 'TestEmote',
        realName: 'RealName',
        width: 32,
        height: 32,
        zeroWidth: true,
        url: 'https://example.com/emote.png',
        type: EmoteType.sevenTVChannel,
        ownerDisplayName: 'Owner',
        ownerUsername: 'owner',
        ownerId: '12345',
      );

      final json = original.toJson();
      final restored = Emote.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.realName, original.realName);
      expect(restored.width, original.width);
      expect(restored.height, original.height);
      expect(restored.zeroWidth, original.zeroWidth);
      expect(restored.url, original.url);
      expect(restored.type, original.type);
      expect(restored.ownerDisplayName, original.ownerDisplayName);
      expect(restored.ownerUsername, original.ownerUsername);
      expect(restored.ownerId, original.ownerId);
    });
  });
}

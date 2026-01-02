import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/badges.dart';

void main() {
  group('ChatBadge.fromTwitch', () {
    test('creates badge with correct properties', () {
      final twitchBadge = BadgeInfoTwitch(
        'https://static-cdn.jtvnw.net/badges/v1/1x.png',
        'https://static-cdn.jtvnw.net/badges/v1/2x.png',
        'https://static-cdn.jtvnw.net/badges/v1/4x.png',
        'subscriber',
        'Subscriber',
        '12 Month Subscriber',
      );

      final badge = ChatBadge.fromTwitch(twitchBadge);

      expect(badge.name, 'Subscriber');
      expect(badge.url, 'https://static-cdn.jtvnw.net/badges/v1/4x.png');
      expect(badge.type, BadgeType.twitch);
      expect(badge.color, isNull);
    });

    test('uses 4x image URL (largest)', () {
      final twitchBadge = BadgeInfoTwitch(
        'https://cdn/1x.png',
        'https://cdn/2x.png',
        'https://cdn/4x.png',
        'mod',
        'Moderator',
        'A moderator',
      );

      final badge = ChatBadge.fromTwitch(twitchBadge);

      expect(badge.url, 'https://cdn/4x.png');
    });

    test('uses title for badge name, not id', () {
      final twitchBadge = BadgeInfoTwitch(
        'url1',
        'url2',
        'url4',
        'vip',
        'VIP',
        'Very Important Person',
      );

      final badge = ChatBadge.fromTwitch(twitchBadge);

      expect(badge.name, 'VIP');
    });
  });

  group('ChatBadge.fromBTTV', () {
    test('creates badge with correct properties', () {
      final bttvBadge = BadgeInfoBTTV(
        '12345',
        BadgeDetailsBTTV('BetterTTV Developer', 'https://cdn.bttv.net/badge.svg'),
      );

      final badge = ChatBadge.fromBTTV(bttvBadge);

      expect(badge.name, 'BetterTTV Developer');
      expect(badge.url, 'https://cdn.bttv.net/badge.svg');
      expect(badge.type, BadgeType.bttv);
      expect(badge.color, isNull);
    });

    test('uses badge description as name', () {
      final bttvBadge = BadgeInfoBTTV(
        '67890',
        BadgeDetailsBTTV('Custom Badge Description', 'https://example.com/badge.svg'),
      );

      final badge = ChatBadge.fromBTTV(bttvBadge);

      expect(badge.name, 'Custom Badge Description');
    });

    test('uses badge SVG URL', () {
      final bttvBadge = BadgeInfoBTTV(
        'providerid',
        BadgeDetailsBTTV('Test Badge', 'https://custom.svg.url/badge.svg'),
      );

      final badge = ChatBadge.fromBTTV(bttvBadge);

      expect(badge.url, 'https://custom.svg.url/badge.svg');
    });
  });

  group('ChatBadge.fromFFZ', () {
    test('creates badge with correct properties including color', () {
      final ffzBadge = BadgeInfoFFZ(
        1,
        'FFZ Supporter',
        '#FF5500',
        const BadgeUrlsFFZ(
          'https://cdn.ffz.net/1x.png',
          'https://cdn.ffz.net/2x.png',
          'https://cdn.ffz.net/4x.png',
        ),
      );

      final badge = ChatBadge.fromFFZ(ffzBadge);

      expect(badge.name, 'FFZ Supporter');
      expect(badge.url, 'https://cdn.ffz.net/4x.png');
      expect(badge.type, BadgeType.ffz);
      expect(badge.color, '#FF5500');
    });

    test('uses 4x image URL', () {
      final ffzBadge = BadgeInfoFFZ(
        2,
        'Test Badge',
        '#00FF00',
        const BadgeUrlsFFZ(
          'https://cdn/1x.png',
          'https://cdn/2x.png',
          'https://cdn/4x.png',
        ),
      );

      final badge = ChatBadge.fromFFZ(ffzBadge);

      expect(badge.url, 'https://cdn/4x.png');
    });

    test('preserves hex color string', () {
      final ffzBadge = BadgeInfoFFZ(
        3,
        'Colored Badge',
        '#ABCDEF',
        const BadgeUrlsFFZ('1x', '2x', '4x'),
      );

      final badge = ChatBadge.fromFFZ(ffzBadge);

      expect(badge.color, '#ABCDEF');
    });

    test('handles various color formats', () {
      // Test lowercase hex
      final ffzBadge1 = BadgeInfoFFZ(
        4,
        'Badge1',
        '#aabbcc',
        const BadgeUrlsFFZ('1x', '2x', '4x'),
      );
      expect(ChatBadge.fromFFZ(ffzBadge1).color, '#aabbcc');

      // Test uppercase hex
      final ffzBadge2 = BadgeInfoFFZ(
        5,
        'Badge2',
        '#AABBCC',
        const BadgeUrlsFFZ('1x', '2x', '4x'),
      );
      expect(ChatBadge.fromFFZ(ffzBadge2).color, '#AABBCC');
    });
  });

  group('ChatBadge.from7TV', () {
    test('creates badge with correct properties', () {
      final badge7TV = BadgeInfo7TV(
        '7TV Subscriber',
        [
          ['1x_url', 'https://cdn.7tv.app/badge/1x.png'],
          ['2x_url', 'https://cdn.7tv.app/badge/2x.png'],
          ['3x_url', 'https://cdn.7tv.app/badge/3x.png'],
        ],
        ['user1', 'user2'],
      );

      final badge = ChatBadge.from7TV(badge7TV);

      expect(badge.name, '7TV Subscriber');
      expect(badge.type, BadgeType.sevenTV);
      expect(badge.color, isNull);
    });

    test('uses urls[2][1] for badge URL (3x size)', () {
      final badge7TV = BadgeInfo7TV(
        'Test Badge',
        [
          ['1x', 'https://cdn.7tv.app/1x.png'],
          ['2x', 'https://cdn.7tv.app/2x.png'],
          ['3x', 'https://cdn.7tv.app/3x.png'],
        ],
        [],
      );

      final badge = ChatBadge.from7TV(badge7TV);

      // urls[2][1] means third array (index 2), second element (index 1)
      expect(badge.url, 'https://cdn.7tv.app/3x.png');
    });

    test('uses tooltip as badge name', () {
      final badge7TV = BadgeInfo7TV(
        'Custom Tooltip Text',
        [
          ['1x', 'url1'],
          ['2x', 'url2'],
          ['3x', 'url3'],
        ],
        [],
      );

      final badge = ChatBadge.from7TV(badge7TV);

      expect(badge.name, 'Custom Tooltip Text');
    });
  });

  group('BadgeType', () {
    test('toString returns human-readable string', () {
      expect(BadgeType.twitch.toString(), 'Twitch badge');
      expect(BadgeType.bttv.toString(), 'BetterTTV badge');
      expect(BadgeType.ffz.toString(), 'FrankerFaceZ badge');
      expect(BadgeType.sevenTV.toString(), '7TV badge');
    });

    test('all badge types have unique toString', () {
      final strings = BadgeType.values.map((t) => t.toString()).toSet();
      expect(strings.length, BadgeType.values.length);
    });
  });

  group('ChatBadge constructor', () {
    test('creates badge with all required fields', () {
      const badge = ChatBadge(
        name: 'Test Badge',
        url: 'https://example.com/badge.png',
        type: BadgeType.twitch,
      );

      expect(badge.name, 'Test Badge');
      expect(badge.url, 'https://example.com/badge.png');
      expect(badge.type, BadgeType.twitch);
      expect(badge.color, isNull);
    });

    test('creates badge with optional color', () {
      const badge = ChatBadge(
        name: 'Colored Badge',
        url: 'https://example.com/badge.png',
        type: BadgeType.ffz,
        color: '#FF0000',
      );

      expect(badge.color, '#FF0000');
    });
  });

  group('BadgeInfoTwitch', () {
    test('fromJson creates correct instance', () {
      final json = {
        'image_url_1x': 'https://cdn/1x.png',
        'image_url_2x': 'https://cdn/2x.png',
        'image_url_4x': 'https://cdn/4x.png',
        'id': 'badge_id',
        'title': 'Badge Title',
        'description': 'Badge Description',
      };

      final badge = BadgeInfoTwitch.fromJson(json);

      expect(badge.imageUrl1x, 'https://cdn/1x.png');
      expect(badge.imageUrl2x, 'https://cdn/2x.png');
      expect(badge.imageUrl4x, 'https://cdn/4x.png');
      expect(badge.id, 'badge_id');
      expect(badge.title, 'Badge Title');
      expect(badge.description, 'Badge Description');
    });
  });

  group('BadgeInfoFFZ', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': 123,
        'title': 'FFZ Badge',
        'color': '#00FF00',
        'urls': {
          '1': 'https://cdn/1x.png',
          '2': 'https://cdn/2x.png',
          '4': 'https://cdn/4x.png',
        },
      };

      final badge = BadgeInfoFFZ.fromJson(json);

      expect(badge.id, 123);
      expect(badge.title, 'FFZ Badge');
      expect(badge.color, '#00FF00');
      expect(badge.urls.url1x, 'https://cdn/1x.png');
      expect(badge.urls.url4x, 'https://cdn/4x.png');
    });
  });

  group('BadgeInfo7TV', () {
    test('fromJson creates correct instance', () {
      final json = {
        'tooltip': '7TV Badge',
        'urls': [
          ['1x', 'https://cdn/1x.png'],
          ['2x', 'https://cdn/2x.png'],
          ['3x', 'https://cdn/3x.png'],
        ],
        'users': ['user1', 'user2', 'user3'],
      };

      final badge = BadgeInfo7TV.fromJson(json);

      expect(badge.tooltip, '7TV Badge');
      expect(badge.urls.length, 3);
      expect(badge.urls[2][1], 'https://cdn/3x.png');
      expect(badge.users, ['user1', 'user2', 'user3']);
    });
  });

  group('BadgeInfoBTTV', () {
    test('fromJson creates correct instance', () {
      final json = {
        'providerId': 'provider123',
        'badge': {
          'description': 'BTTV Badge',
          'svg': 'https://cdn.bttv.net/badge.svg',
        },
      };

      final badge = BadgeInfoBTTV.fromJson(json);

      expect(badge.providerId, 'provider123');
      expect(badge.badge.description, 'BTTV Badge');
      expect(badge.badge.svg, 'https://cdn.bttv.net/badge.svg');
    });
  });
}

/// Test fixtures containing sample API response data.
/// Reused across model serialization and API service tests.
library;

// ── Twitch API Responses ──

const twitchEmotesGlobalResponse = {
  'data': [
    {
      'id': '25',
      'name': 'Kappa',
      'emote_type': 'bitstier',
      'owner_id': null,
    },
    {
      'id': '1902',
      'name': 'Keepo',
      'emote_type': 'globals',
      'owner_id': null,
    },
  ],
};

const twitchBadgesGlobalResponse = {
  'data': [
    {
      'set_id': 'subscriber',
      'versions': [
        {
          'id': '0',
          'image_url_1x': 'https://cdn/sub/1x.png',
          'image_url_2x': 'https://cdn/sub/2x.png',
          'image_url_4x': 'https://cdn/sub/4x.png',
          'title': 'Subscriber',
          'description': '0 months',
        },
      ],
    },
  ],
};

const twitchUserResponse = {
  'data': [
    {
      'id': '12345',
      'login': 'testuser',
      'display_name': 'TestUser',
      'profile_image_url': 'https://cdn/profile.png',
    },
  ],
};

const twitchStreamResponse = {
  'data': [
    {
      'user_id': '12345',
      'user_login': 'testuser',
      'user_name': 'TestUser',
      'game_id': '509658',
      'game_name': 'Just Chatting',
      'title': 'Test Stream',
      'viewer_count': 1000,
      'started_at': '2024-01-01T00:00:00Z',
      'thumbnail_url': 'https://cdn/thumb.jpg',
    },
  ],
  'pagination': {'cursor': 'next_cursor'},
};

const twitchCategoryResponse = {
  'data': [
    {
      'box_art_url': 'https://cdn/boxart.jpg',
      'id': '509658',
      'name': 'Just Chatting',
    },
  ],
  'pagination': {'cursor': 'cat_cursor'},
};

const twitchChannelResponse = {
  'data': [
    {
      'broadcaster_id': '12345',
      'broadcaster_login': 'testuser',
      'broadcaster_name': 'TestUser',
      'broadcaster_language': 'en',
      'title': 'Test Stream',
      'game_id': '509658',
      'game_name': 'Just Chatting',
    },
  ],
};

const twitchChannelQueryResponse = {
  'data': [
    {
      'broadcaster_login': 'testuser',
      'display_name': 'TestUser',
      'id': '12345',
      'is_live': true,
      'started_at': '2024-01-01T00:00:00Z',
    },
  ],
};

const twitchBlockedUsersResponse = {
  'data': [
    {
      'user_id': '99999',
      'user_login': 'blockeduser',
      'display_name': 'BlockedUser',
    },
  ],
  'pagination': {'cursor': null},
};

const twitchSharedChatSessionResponse = {
  'data': [
    {
      'session_id': 'session_123',
      'host_broadcaster_id': '12345',
      'participants': [
        {'broadcaster_id': '12345'},
        {'broadcaster_id': '67890'},
      ],
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T01:00:00Z',
    },
  ],
};

const twitchTokenResponse = {
  'access_token': 'test_token_abc123',
  'token_type': 'bearer',
  'expires_in': 5000000,
};

const twitchValidateTokenResponse = {
  'client_id': 'test_client_id',
  'login': 'testuser',
  'scopes': ['chat:read', 'chat:edit'],
  'user_id': '12345',
  'expires_in': 5000000,
};

// ── BTTV API Responses ──

const bttvEmotesGlobalResponse = [
  {'id': 'bttv1', 'code': 'SourPls'},
  {'id': 'bttv2', 'code': 'catJAM'},
];

const bttvEmotesChannelResponse = {
  'channelEmotes': [
    {'id': 'ch1', 'code': 'ChannelEmote'},
  ],
  'sharedEmotes': [
    {'id': 'sh1', 'code': 'SharedEmote'},
    {'id': 'sh2', 'code': 'SharedEmote2'},
  ],
};

const bttvBadgesResponse = [
  {
    'providerId': 'user123',
    'badge': {
      'description': 'BTTV Developer',
      'svg': 'https://cdn.bttv.net/badge/dev.svg',
    },
  },
  {
    'providerId': 'user456',
    'badge': {
      'description': 'BTTV Supporter',
      'svg': 'https://cdn.bttv.net/badge/supporter.svg',
    },
  },
];

// ── FFZ API Responses ──

const ffzEmotesGlobalResponse = {
  'default_sets': [1],
  'sets': {
    '1': {
      'emoticons': [
        {
          'name': 'LULW',
          'height': 28,
          'width': 28,
          'owner': {'display_name': 'FFZOwner', 'name': 'ffzowner'},
          'urls': {
            '1': 'https://cdn.ffz.net/1x.png',
            '2': 'https://cdn.ffz.net/2x.png',
            '4': 'https://cdn.ffz.net/4x.png',
          },
          'animated': null,
        },
      ],
    },
  },
};

const ffzRoomInfoResponse = {
  'room': {
    'set': 123,
    'vip_badge': null,
    'mod_urls': null,
  },
  'sets': {
    '123': {
      'emoticons': [
        {
          'name': 'ChannelFFZ',
          'height': 32,
          'width': 32,
          'owner': {'display_name': 'Streamer', 'name': 'streamer'},
          'urls': {
            '1': 'https://cdn.ffz.net/ch/1x.png',
            '2': 'https://cdn.ffz.net/ch/2x.png',
            '4': 'https://cdn.ffz.net/ch/4x.png',
          },
          'animated': null,
        },
      ],
    },
  },
};

const ffzBadgesResponse = {
  'badges': [
    {
      'id': 1,
      'title': 'FFZ Developer',
      'color': '#FF0000',
      'urls': {
        '1': 'https://cdn.ffz.net/badge/1x.png',
        '2': 'https://cdn.ffz.net/badge/2x.png',
        '4': 'https://cdn.ffz.net/badge/4x.png',
      },
    },
    {
      'id': 2,
      'title': 'FFZ Supporter',
      'color': '#00FF00',
      'urls': {
        '1': 'https://cdn.ffz.net/badge2/1x.png',
        '2': 'https://cdn.ffz.net/badge2/2x.png',
        '4': 'https://cdn.ffz.net/badge2/4x.png',
      },
    },
  ],
  'users': {
    '1': [11111, 22222],
    '2': [22222, 33333],
  },
};

// ── 7TV API Responses ──

const sevenTVEmotesGlobalResponse = {
  'emotes': [
    {
      'id': '7tv1',
      'name': 'EZ',
      'data': {
        'id': '7tv1',
        'name': 'EZ',
        'flags': 0,
        'owner': {'username': 'creator', 'display_name': 'Creator'},
        'host': {
          'url': '//cdn.7tv.app/emote/7tv1',
          'files': [
            {'name': '1x.webp', 'width': 32, 'height': 32, 'format': 'WEBP'},
            {'name': '2x.webp', 'width': 64, 'height': 64, 'format': 'WEBP'},
            {'name': '3x.webp', 'width': 96, 'height': 96, 'format': 'WEBP'},
            {
              'name': '4x.webp',
              'width': 128,
              'height': 128,
              'format': 'WEBP',
            },
          ],
        },
      },
    },
  ],
};

const sevenTVEmotesChannelResponse = {
  'emote_set': {
    'id': 'set_abc123',
    'emotes': [
      {
        'id': '7tv_ch1',
        'name': 'Clap',
        'data': {
          'id': '7tv_ch1',
          'name': 'Clap',
          'flags': 0,
          'owner': null,
          'host': {
            'url': '//cdn.7tv.app/emote/7tv_ch1',
            'files': [
              {
                'name': '1x.webp',
                'width': 32,
                'height': 32,
                'format': 'WEBP',
              },
              {
                'name': '4x.webp',
                'width': 128,
                'height': 128,
                'format': 'WEBP',
              },
            ],
          },
        },
      },
    ],
  },
};

// ── Chatters Response ──

const chattersResponse = {
  'chatter_count': 5,
  'chatters': {
    'broadcaster': ['streamer'],
    'vips': ['vip1'],
    'moderators': ['mod1'],
    'staff': <String>[],
    'admins': <String>[],
    'global_mods': <String>[],
    'viewers': ['viewer1', 'viewer2'],
  },
};

// ── 7TV Events ──

const sevenTVEventJson = {
  'op': 0,
  't': 1,
  'd': {
    'type': 'emote_set.update',
    'condition': {'object_id': 'set_abc123'},
  },
};

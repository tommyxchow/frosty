import 'package:frosty/models/channel.dart';

/// The twitch IRC websocket channel.
const twitchIrcUrl = 'wss://irc-ws.chat.twitch.tv:443';

/// The URL for getting Twitch user information.
const twitchUsersUrl = 'https://api.twitch.tv/helix/users';

/// The URL for validating Twitch OAuth tokens.
const twitchValidateUrl = 'https://id.twitch.tv/oauth2/validate';

/// Sample channel objects for testing/preview purposes.
const SampleChannels = [
  Channel(
      id: '',
      userId: '',
      userLogin: 'xqcow',
      userName: 'xQcOW',
      gameId: '',
      gameName: 'VALORANT',
      type: 'live',
      title: 'TITANIC MAN WITH UNREAL UNMATCHED UNBELIEVABLE STRENGHT AND APTITUDE ACCOMPLISHES ACHIEVEMENTS DEEMED IMPOSSIBLE BY THE PUBLIC (GONE WRONG)',
      viewerCount: 76422,
      startedAt: '',
      language: 'en',
      thumbnailUrl: 'https://static-cdn.jtvnw.net/previews-ttv/live_user_xqcow-{width}x{height}.jpg',
      tagIds: [],
      isMature: false),
  Channel(
      id: '',
      userId: '',
      userLogin: 'lirik',
      userName: 'Lirik',
      gameId: '',
      gameName: 'Just Chatting',
      type: 'live',
      title: 'LOL',
      viewerCount: 11933,
      startedAt: '',
      language: 'en',
      thumbnailUrl: 'https://static-cdn.jtvnw.net/previews-ttv/live_user_lirik-{width}x{height}.jpg',
      tagIds: [],
      isMature: false),
  Channel(
      id: '',
      userId: '',
      userLogin: 'mizkif',
      userName: 'Mizkif',
      gameId: '',
      gameName: 'Just Chatting',
      type: 'live',
      title: 'DRAMA DRAMA DRAMA',
      viewerCount: 4547,
      startedAt: '',
      language: 'en',
      thumbnailUrl: 'https://static-cdn.jtvnw.net/previews-ttv/live_user_mizkif-{width}x{height}.jpg',
      tagIds: [],
      isMature: false)
];

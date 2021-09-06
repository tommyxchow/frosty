import 'package:frosty/models/channel.dart';

const clientId = const String.fromEnvironment('CLIENT_ID');

const secret = const String.fromEnvironment('SECRET');

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

import 'package:frosty/models/stream.dart';

const clientId = String.fromEnvironment('CLIENT_ID');

const secret = String.fromEnvironment('SECRET');

/// Sample channel objects for testing/preview purposes.
const sampleChannels = [
  Stream(
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
  Stream(
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
  Stream(
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

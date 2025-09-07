import 'package:flutter/material.dart';

/// Twitch API client ID.
const clientId = String.fromEnvironment('CLIENT_ID');

/// Twitch API client secret.
const secret = String.fromEnvironment('SECRET');

/// BTTV emotes with zero width to allow for overlaying other emotes.
const zeroWidthEmotes = [
  'SoSnowy',
  'IceCold',
  'SantaHat',
  'TopHat',
  'ReinDeer',
  'CandyCane',
  'cvMask',
  'cvHazmat',
];

/// Regex for matching strings that contain lower or upper case English characters.
final regexEnglish = RegExp(r'[a-zA-Z]');

/// Regex for matching URLs and file names in text.
final regexLink = RegExp(
  r'(?<![A-Za-z0-9_.-])' // left boundary
  r'(?:' // ───────── URL ─────────
  r'(?:www\.)?' // optional www.
  r'(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+'
  r'[A-Za-z]{2,63}' // TLD
  r'(?::\d{1,5})?' // optional :port
  r'(?:/[^\s]*)?' // optional path / query / hash
  r'|' // ───── file names ──────
  r'[A-Za-z0-9_-]+\.(?:' // bare `doom.exe`, `logo.png`, …
  r'exe|png|jpe?g|gif|bmp|webp|mp4|avi|zip|rar|pdf'
  r')'
  r')'
  r'(?![A-Za-z0-9-])', // right boundary
  caseSensitive: false,
);

/// The default badge width and height.
const defaultBadgeSize = 18.0;

/// The default emote width and height when none are provided.
const defaultEmoteSize = 28.0;

/// Available named chat colors for Twitch users.
const chatColorNames = [
  'blue',
  'blue_violet',
  'cadet_blue',
  'chocolate',
  'coral',
  'dodger_blue',
  'firebrick',
  'golden_rod',
  'green',
  'hot_pink',
  'orange_red',
  'red',
  'sea_green',
  'spring_green',
  'yellow_green',
];

/// Color values for the named chat colors.
const Map<String, Color> chatColorValues = {
  'blue': Color(0xFF0000FF),
  'blue_violet': Color(0xFF8A2BE2),
  'cadet_blue': Color(0xFF5F9EA0),
  'chocolate': Color(0xFFD2691E),
  'coral': Color(0xFFFF7F50),
  'dodger_blue': Color(0xFF1E90FF),
  'firebrick': Color(0xFFB22222),
  'golden_rod': Color(0xFFDAA520),
  'green': Color(0xFF008000),
  'hot_pink': Color(0xFFFF69B4),
  'orange_red': Color(0xFFFF4500),
  'red': Color(0xFFFF0000),
  'sea_green': Color(0xFF2E8B57),
  'spring_green': Color(0xFF00FF7F),
  'yellow_green': Color(0xFF9ACD32),
};

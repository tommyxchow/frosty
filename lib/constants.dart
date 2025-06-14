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

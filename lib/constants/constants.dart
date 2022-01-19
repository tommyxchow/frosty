/// Twitch API client ID.
const clientId = String.fromEnvironment('CLIENT_ID');

/// Twitch API client secret.
const secret = String.fromEnvironment('SECRET');

/// The current version of the app.
const appVersion = '1.0.0-beta+8';

/// The tracesSampleRate for sentry crash reporting.
const sampleRate = 1.0;

/// BTTV emotes with zero width to allow for overlaying other emotes.
const zeroWidthEmotes = [
  "SoSnowy",
  "IceCold",
  "SantaHat",
  "TopHat",
  "ReinDeer",
  "CandyCane",
  "cvMask",
  "cvHazmat",
];

// Regex for matching strings that contain lower or upper case English characters.
final regexEnglish = RegExp(r'[a-zA-Z]');

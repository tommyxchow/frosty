/// Core OAuth scopes Frosty requests on a normal Twitch login.
///
/// Matches the pre-moderator-tools set so existing tokens remain valid without
/// a re-consent nag for non-moderators.
const twitchUserScopes = <String>[
  'chat:read',
  'chat:edit',
  'user:read:follows',
  'user:read:blocked_users',
  'user:manage:blocked_users',
  'user:manage:chat_color',
  'user:read:emotes',
];

/// Moderator-only scopes requested via an explicit opt-in upgrade.
const twitchModeratorScopes = <String>[
  'user:read:moderated_channels',
  'moderator:manage:chat_messages',
  'moderator:manage:banned_users',
];

/// Core + moderator scopes for an opted-in moderator session.
const twitchAllUserScopes = <String>[
  ...twitchUserScopes,
  ...twitchModeratorScopes,
];

/// Space-separated scope string for Twitch's authorize URL (core only).
String get twitchUserScopeQuery => twitchUserScopes.join(' ');

/// Space-separated scope string for Twitch's authorize URL (core + mod).
String get twitchAllUserScopeQuery => twitchAllUserScopes.join(' ');

/// Human-readable labels for Frosty-requested scopes.
const twitchScopeLabels = <String, String>{
  'chat:read': 'Read chat messages',
  'chat:edit': 'Send chat messages',
  'user:read:follows': 'View followed channels',
  'user:read:blocked_users': 'View blocked users',
  'user:manage:blocked_users': 'Block and unblock users',
  'user:manage:chat_color': 'Change chat name color',
  'user:read:emotes': 'View emotes you can use',
  'user:read:moderated_channels': 'View channels you moderate',
  'moderator:manage:chat_messages': 'Delete chat messages as a moderator',
  'moderator:manage:banned_users': 'Timeout and ban users as a moderator',
};

/// Whether [granted] includes every moderator scope Frosty needs.
bool hasModeratorScopes(Iterable<String> granted) =>
    missingTwitchScopes(
      granted: granted,
      required: twitchModeratorScopes,
    ).isEmpty;

/// Scopes in [required] that are not present in [granted].
List<String> missingTwitchScopes({
  required Iterable<String> granted,
  Iterable<String> required = twitchUserScopes,
}) {
  final grantedSet = granted.toSet();
  return required.where((scope) => !grantedSet.contains(scope)).toList();
}

String _scopeBullets(Iterable<String> scopes) => scopes
    .map((scope) => '• ${twitchScopeLabels[scope] ?? scope}')
    .join('\n');

/// Dialog body for a Twitch Helix/OAuth 401 on a core (non-mod) request.
///
/// Missing-permissions copy only lists **core** scopes. A token that already
/// has core scopes is treated as expired/invalid rather than "missing mod
/// permissions" so non-mods are never nagged about moderator consent.
String unauthorizedDialogMessage({
  required bool isLoggedIn,
  required Iterable<String> grantedScopes,
}) {
  if (!isLoggedIn) {
    return 'Your session has expired. Please log in again to continue.';
  }

  final missing = missingTwitchScopes(granted: grantedScopes);
  if (missing.isEmpty) {
    return 'Your session has expired. Please log in again to continue.';
  }

  return 'Frosty needs additional Twitch permissions:\n\n'
      '${_scopeBullets(missing)}\n\n'
      'Log in again to grant them.';
}

/// Copy for the explicit moderator-tools opt-in dialog.
String enableModeratorToolsDialogMessage() {
  return 'Enable moderator tools to manage chat in channels you moderate:\n\n'
      '${_scopeBullets(twitchModeratorScopes)}\n\n'
      'You will be asked to authorize these permissions with Twitch.';
}

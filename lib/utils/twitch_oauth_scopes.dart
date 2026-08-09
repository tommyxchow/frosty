/// OAuth scopes Frosty requests for a logged-in Twitch user session.
const twitchUserScopes = <String>[
  'chat:read',
  'chat:edit',
  'user:read:follows',
  'user:read:blocked_users',
  'user:manage:blocked_users',
  'user:manage:chat_color',
  'user:read:moderated_channels',
  'moderator:manage:chat_messages',
  'moderator:manage:banned_users',
];

/// Space-separated scope string for Twitch's authorize URL.
String get twitchUserScopeQuery => twitchUserScopes.join(' ');

/// Human-readable labels for [twitchUserScopes].
const twitchScopeLabels = <String, String>{
  'chat:read': 'Read chat messages',
  'chat:edit': 'Send chat messages',
  'user:read:follows': 'View followed channels',
  'user:read:blocked_users': 'View blocked users',
  'user:manage:blocked_users': 'Block and unblock users',
  'user:manage:chat_color': 'Change chat name color',
  'user:read:moderated_channels': 'View channels you moderate',
  'moderator:manage:chat_messages': 'Delete chat messages as a moderator',
  'moderator:manage:banned_users': 'Timeout and ban users as a moderator',
};

/// Scopes in [required] that are not present in [granted].
List<String> missingTwitchScopes({
  required Iterable<String> granted,
  Iterable<String> required = twitchUserScopes,
}) {
  final grantedSet = granted.toSet();
  return required.where((scope) => !grantedSet.contains(scope)).toList();
}

/// Dialog body for a Twitch Helix/OAuth 401.
String unauthorizedDialogMessage({
  required bool isLoggedIn,
  required Iterable<String> grantedScopes,
}) {
  if (!isLoggedIn) {
    return 'Your session has expired. Please log in again to continue.';
  }

  final missing = missingTwitchScopes(granted: grantedScopes);
  if (missing.isEmpty) {
    return 'Your session is missing permissions. Please log in again to continue.';
  }

  final bullets = missing
      .map((scope) => '• ${twitchScopeLabels[scope] ?? scope}')
      .join('\n');

  return 'Frosty needs additional Twitch permissions:\n\n'
      '$bullets\n\n'
      'Log in again to grant them.';
}

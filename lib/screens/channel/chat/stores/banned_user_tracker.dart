/// Tracks which users are currently banned or timed out, learned from IRC
/// CLEARCHAT events, so the chat can offer an "unban / remove timeout" action
/// only when it's actually applicable.
///
/// Keyed by Twitch user id. A value of null means a permanent ban; a non-null
/// [DateTime] is when a timeout expires. Pure logic (clock passed in) so it can
/// be unit-tested without the chat store.
class BannedUserTracker {
  final _expiries = <String, DateTime?>{};

  /// Record a permanent ban (CLEARCHAT without a ban-duration).
  void recordBan(String userId) => _expiries[userId] = null;

  /// Record a timeout (CLEARCHAT with a ban-duration), expiring at [now] + [duration].
  void recordTimeout(String userId, Duration duration, DateTime now) =>
      _expiries[userId] = now.add(duration);

  /// Forget a user (e.g. after a successful unban).
  void clear(String userId) => _expiries.remove(userId);

  /// Whether [userId] is currently banned or within an unexpired timeout.
  /// Expired timeouts are pruned on read.
  bool isBannedOrTimedOut(String userId, DateTime now) {
    if (!_expiries.containsKey(userId)) return false;
    final expiry = _expiries[userId];
    if (expiry == null) return true; // permanent ban
    if (now.isBefore(expiry)) return true; // timeout still active
    _expiries.remove(userId); // expired — clean up
    return false;
  }
}

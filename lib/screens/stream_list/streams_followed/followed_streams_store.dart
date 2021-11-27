import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/stream.dart';
import 'package:mobx/mobx.dart';

part 'followed_streams_store.g.dart';

class FollowedStreamsStore = _FollowedStreamsStoreBase with _$FollowedStreamsStore;

abstract class _FollowedStreamsStoreBase with Store {
  /// The list of the fetched followed streams.
  @observable
  var _followedStreams = ObservableList<StreamTwitch>();
  ObservableList<StreamTwitch> get followedStreams => _followedStreams;

  /// The loading status for pagination.
  bool _isLoading = false;

  /// The pagination cursor for followed streams.
  String? _followedStreamsCurrentCursor;

  /// The authentication store.
  final AuthStore authStore;

  /// Returns whether or not there are more streams and loading status for pagination.
  bool get hasMore => _isLoading == false && _followedStreamsCurrentCursor != null;

  _FollowedStreamsStoreBase({required this.authStore}) {
    if (authStore.isLoggedIn) getFollowedStreams();
  }

  /// Fetches the followed streams based on the current cursor.
  @action
  Future<void> getFollowedStreams() async {
    _isLoading = true;

    final newFollowedStreams = await Twitch.getFollowedStreams(id: authStore.user!.id, headers: authStore.headersTwitch, cursor: _followedStreamsCurrentCursor);

    if (newFollowedStreams != null) {
      if (_followedStreamsCurrentCursor == null) {
        _followedStreams = ObservableList.of(newFollowedStreams.data);
      } else {
        _followedStreams.addAll(newFollowedStreams.data);
      }
      _followedStreamsCurrentCursor = newFollowedStreams.pagination['cursor'];
    }

    _isLoading = false;
  }

  /// Resets the cursor and then fetches the followed streams.
  @action
  Future<void> refresh() {
    _followedStreamsCurrentCursor = null;

    return getFollowedStreams();
  }
}

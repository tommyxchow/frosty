import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:mobx/mobx.dart';

part 'stream_list_store.g.dart';

// TODO: Fix followed list refresh when log in.
class StreamListStore = _StreamListBase with _$StreamListStore;

abstract class _StreamListBase with Store {
  /// The list of the fetched top streams.
  @observable
  var _topStreams = ObservableList<Stream>();

  /// The list of the fetched followed streams.
  @observable
  var _followedStreams = ObservableList<Stream>();

  /// The loading status for pagination.
  bool _isLoading = false;

  /// The pagination cursor for top streams.
  String? _topStreamsCurrentCursor;

  /// The pagination cursor for followed streams.
  String? _followedStreamsCurrentCursor;

  /// The authentication store.
  final AuthStore authStore;

  _StreamListBase({required this.authStore}) {
    getStreams(category: StreamCategory.top);

    if (authStore.user?.id != null) {
      getStreams(category: StreamCategory.followed);
    }
  }

  /// Returns the appropriate streams given the [category].
  ObservableList<Stream> streams({required StreamCategory category}) {
    switch (category) {
      case StreamCategory.top:
        return _topStreams;
      case StreamCategory.followed:
        return _followedStreams;
    }
  }

  /// Returns whether or not there are more streams for the [category].
  bool hasMore({required StreamCategory category}) {
    switch (category) {
      case StreamCategory.top:
        return _isLoading == false && _topStreamsCurrentCursor != null;
      case StreamCategory.followed:
        return _isLoading == false && _followedStreamsCurrentCursor != null;
    }
  }

  /// Resets the cursor and then fetches the streams for the [category].
  @action
  Future<void> refresh({required StreamCategory category}) async {
    switch (category) {
      case StreamCategory.top:
        _topStreamsCurrentCursor = null;
        break;
      case StreamCategory.followed:
        _followedStreamsCurrentCursor = null;
        break;
    }

    await getStreams(category: category);
  }

  /// Fetches the streams for the [category] based on the current cursor.
  @action
  Future<void> getStreams({required StreamCategory category}) async {
    _isLoading = true;

    switch (category) {
      case StreamCategory.top:
        final newTopStreams = await Twitch.getTopStreams(headers: authStore.headersTwitch, cursor: _topStreamsCurrentCursor);

        if (newTopStreams != null) {
          if (_topStreamsCurrentCursor == null) {
            _topStreams = ObservableList.of(newTopStreams['streams']);
          } else {
            _topStreams.addAll(newTopStreams['streams']);
          }
          _topStreamsCurrentCursor = newTopStreams['cursor'];
        }
        break;
      case StreamCategory.followed:
        final newFollowedStreams =
            await Twitch.getFollowedStreams(id: authStore.user!.id, headers: authStore.headersTwitch, cursor: _followedStreamsCurrentCursor);

        if (newFollowedStreams != null) {
          if (_followedStreamsCurrentCursor == null) {
            _followedStreams = ObservableList.of(newFollowedStreams['streams']);
          } else {
            _followedStreams.addAll(newFollowedStreams['streams']);
          }
          _followedStreamsCurrentCursor = newFollowedStreams['cursor'];
        }
        break;
    }

    _isLoading = false;
  }
}

/// The type of category for streams.
enum StreamCategory { top, followed }

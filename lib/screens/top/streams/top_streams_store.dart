import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/stream.dart';
import 'package:mobx/mobx.dart';

part 'top_streams_store.g.dart';

class TopStreamsStore = _TopStreamsStoreBase with _$TopStreamsStore;

abstract class _TopStreamsStoreBase with Store {
  /// The list of the fetched top streams.
  @readonly
  var _topStreams = ObservableList<StreamTwitch>();

  /// The loading status for pagination.
  @readonly
  bool _isLoading = false;

  /// The pagination cursor for top streams.
  String? _topStreamsCurrentCursor;

  /// The authentication store.
  final AuthStore authStore;

  /// Returns whether or not there are more streams and loading status for pagination.
  bool get hasMore => _isLoading == false && _topStreamsCurrentCursor != null;

  _TopStreamsStoreBase({required this.authStore}) {
    getTopStreams();
  }

  /// Fetches the top streams based on the current cursor.
  @action
  Future<void> getTopStreams() async {
    _isLoading = true;

    final newTopStreams = await Twitch.getTopStreams(
      headers: authStore.headersTwitch,
      cursor: _topStreamsCurrentCursor,
    );

    if (newTopStreams != null) {
      if (_topStreamsCurrentCursor == null) {
        _topStreams = newTopStreams.data.asObservable();
      } else {
        _topStreams.addAll(newTopStreams.data);
      }
      _topStreamsCurrentCursor = newTopStreams.pagination['cursor'];
    }

    _isLoading = false;
  }

  /// Resets the cursor and then fetches the top streams.
  @action
  Future<void> refresh() {
    _topStreamsCurrentCursor = null;

    return getTopStreams();
  }
}

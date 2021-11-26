import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/models/stream.dart';
import 'package:mobx/mobx.dart';

part 'category_streams_store.g.dart';

class CategoryStreamsStore = _CategoryStreamsStoreBase with _$CategoryStreamsStore;

abstract class _CategoryStreamsStoreBase with Store {
  final CategoryTwitch categoryInfo;

  /// The list of the fetched streams under the category.
  @observable
  var _streams = ObservableList<StreamTwitch>();
  ObservableList<StreamTwitch> get streams => _streams;

  /// The loading status for pagination.
  bool _isLoading = false;

  /// The pagination cursor for streams under the category.
  String? streamsCurrentCursor;

  /// The authentication store used for obtaining the request headers.
  final AuthStore authStore;

  /// Returns whether or not there are more streams and loading status for pagination.
  bool get hasMore => _isLoading == false && streamsCurrentCursor != null;

  _CategoryStreamsStoreBase({
    required this.categoryInfo,
    required this.authStore,
  }) {
    getStreams();
  }

  /// Fetches the streams under the category based on the current cursor.
  @action
  Future<void> getStreams() async {
    _isLoading = true;

    final newStreams = await Twitch.getStreamsUnderGame(
      gameId: categoryInfo.id,
      headers: authStore.headersTwitch,
      cursor: streamsCurrentCursor,
    );

    if (newStreams != null) {
      if (streamsCurrentCursor == null) {
        _streams = ObservableList.of(newStreams.data);
      } else {
        _streams.addAll(newStreams.data);
      }
      streamsCurrentCursor = newStreams.pagination['cursor'];
    }

    _isLoading = false;
  }

  /// Resets the cursor and then fetches the streams under the category.
  @action
  Future<void> refresh() async {
    streamsCurrentCursor = null;

    await getStreams();
  }
}

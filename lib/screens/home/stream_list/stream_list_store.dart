import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';

part 'stream_list_store.g.dart';

class ListStore = ListStoreBase with _$ListStore;

abstract class ListStoreBase with Store {
  /// The authentication store.
  final AuthStore authStore;

  final SettingsStore settingsStore;

  /// Twitch API service class for making requests.
  final TwitchApi twitchApi;

  /// The type of list that this store is handling.
  final ListType listType;

  /// The category id to use when fetching streams if the [listType] is [ListType.category].
  final String? categoryId;

  /// The scroll controller used for handling scroll to top (if provided).
  /// If provided, will use the [ScrollToTop] widget to scroll to the top of the list instead of the bottom tab bar.
  final ScrollController? scrollController;

  /// The pagination cursor for the streams.
  String? _streamsCursor;

  /// The last time the streams were refreshed/updated.
  var lastTimeRefreshed = DateTime.now();

  /// Returns whether or not there are more streams and loading status for pagination.
  @computed
  bool get hasMore => isLoading == false && _streamsCursor != null;

  @computed
  bool get isLoading =>
      _isAllStreamsLoading ||
      _isPinnedStreamsLoading ||
      _isCategoryDetailsLoading;

  /// The loading status for pagination.

  /// The list of the fetched streams.
  @readonly
  var _allStreams = ObservableList<StreamTwitch>();

  @readonly
  bool _isAllStreamsLoading = false;

  @readonly
  var _pinnedStreams = ObservableList<StreamTwitch>();

  @readonly
  var _isPinnedStreamsLoading = false;

  @readonly
  CategoryTwitch? _categoryDetails;

  @readonly
  var _isCategoryDetailsLoading = false;

  /// Whether or not the scroll to top button is visible.
  @observable
  var showJumpButton = false;

  /// The list of the fetched streams with blocked users filtered out.
  @computed
  ObservableList<StreamTwitch> get streams => _allStreams
      .where(
        (streamInfo) => !authStore.user.blockedUsers
            .map((blockedUser) => blockedUser.userId)
            .contains(streamInfo.userId),
      )
      .toList()
      .asObservable();

  /// The error message to show if any. Will be non-null if there is an error.
  @readonly
  String? _error;

  ReactionDisposer? _pinnedStreamsReactioniDisposer;

  ListStoreBase({
    required this.authStore,
    required this.settingsStore,
    required this.twitchApi,
    required this.listType,
    this.categoryId,
    this.scrollController,
  }) {
    if (scrollController != null) {
      scrollController!.addListener(() {
        if (scrollController!.position.atEdge ||
            scrollController!.position.outOfRange) {
          showJumpButton = false;
        } else {
          showJumpButton = true;
        }
      });
    }

    if (listType == ListType.followed) {
      _pinnedStreamsReactioniDisposer = reaction(
        (_) => settingsStore.pinnedChannelIds,
        (_) => getPinnedStreams(),
      );

      getPinnedStreams();
    }

    if (listType == ListType.category) {
      _getCategoryDetails();
    }

    getStreams();
  }

  /// Fetches the streams based on the type and current cursor.
  @action
  Future<void> getStreams() async {
    _isAllStreamsLoading = true;

    try {
      final StreamsTwitch newStreams;
      switch (listType) {
        case ListType.followed:
          newStreams = await twitchApi.getFollowedStreams(
            id: authStore.user.details!.id,
            headers: authStore.headersTwitch,
            cursor: _streamsCursor,
          );
          break;
        case ListType.top:
          newStreams = await twitchApi.getTopStreams(
            headers: authStore.headersTwitch,
            cursor: _streamsCursor,
          );
          break;
        case ListType.category:
          newStreams = await twitchApi.getStreamsUnderCategory(
            gameId: categoryId!,
            headers: authStore.headersTwitch,
            cursor: _streamsCursor,
          );
          break;
      }

      if (_streamsCursor == null) {
        _allStreams = newStreams.data.asObservable();
      } else {
        _allStreams.addAll(newStreams.data);
      }
      _streamsCursor = newStreams.pagination['cursor'];

      _error = null;
    } on SocketException {
      _error = 'Failed to connect';
    } catch (e) {
      _error = e.toString();
    }

    _isAllStreamsLoading = false;
  }

  @action
  Future<void> getPinnedStreams() async {
    if (settingsStore.pinnedChannelIds.isEmpty) {
      _pinnedStreams.clear();
      return;
    }

    _isPinnedStreamsLoading = true;

    try {
      _pinnedStreams = (await twitchApi.getStreamsByIds(
        userIds: settingsStore.pinnedChannelIds,
        headers: authStore.headersTwitch,
      ))
          .data
          .asObservable();

      _error = null;
    } on SocketException {
      _error = 'Failed to connect';
    } catch (e) {
      _error = e.toString();
    }

    _isPinnedStreamsLoading = false;
  }

  /// Resets the cursor and then fetches the streams.
  @action
  Future<void> refreshStreams() async {
    if (listType == ListType.followed) await getPinnedStreams();

    _streamsCursor = null;
    await getStreams();
  }

  @action
  Future<void> _getCategoryDetails() async {
    if (categoryId == null) return;

    _isCategoryDetailsLoading = true;

    final categoryDetails = await twitchApi.getCategory(
      headers: authStore.headersTwitch,
      gameId: categoryId!,
    );

    _categoryDetails = categoryDetails.data.first;

    _isCategoryDetailsLoading = false;
  }

  /// Checks the last time the streams were refreshed and updates them if it has been more than 5 minutes.
  void checkLastTimeRefreshedAndUpdate() {
    final now = DateTime.now();
    final difference = now.difference(lastTimeRefreshed);

    if (difference.inMinutes >= 5) refreshStreams();

    lastTimeRefreshed = now;
  }

  void dispose() {
    _pinnedStreamsReactioniDisposer?.call();

    scrollController?.dispose();
  }
}

/// The possible types of lists that can be displayed.
///
/// [ListType.followed] is the list of streams that the user is following.
/// [ListType.top] is the list of top streams.
/// [ListType.category] is the list of streams under a category.
enum ListType {
  followed,
  top,
  category,
}

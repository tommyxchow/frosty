import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/stream.dart';
import 'package:mobx/mobx.dart';

part 'list_store.g.dart';

class ListStore = ListStoreBase with _$ListStore;

abstract class ListStoreBase with Store {
  /// The authentication store.
  final AuthStore authStore;

  /// Twitch API service class for making requests.
  final TwitchApi twitchApi;

  /// The type of list that this store is handling.
  final ListType listType;

  /// The category id to use if the [listType] is [ListType.category].
  final String? categoryId;

  /// The pagination cursor for the streams.
  String? _streamsCursor;

  /// Returns whether or not there are more streams and loading status for pagination.
  bool get hasMore => _isLoading == false && _streamsCursor != null;

  /// The loading status for pagination.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// The scroll controller used for handling scroll to top.
  final scrollController = ScrollController();

  /// Whether or not the scroll to top button is visible.
  @observable
  var showJumpButton = false;

  /// The list of the fetched streams.
  @readonly
  var _allStreams = ObservableList<StreamTwitch>();

  /// The list of the fetched streams with blocked users filtered out.
  @computed
  ObservableList<StreamTwitch> get streams => _allStreams
      .where((streamInfo) => !authStore.user.blockedUsers.map((blockedUser) => blockedUser.userId).contains(streamInfo.userId))
      .toList()
      .asObservable();

  /// The error message to show if any. Will be non-null if there is an error.
  @readonly
  String? _error;

  ListStoreBase({
    required this.authStore,
    required this.twitchApi,
    required this.listType,
    this.categoryId,
  }) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge || scrollController.position.outOfRange) {
        showJumpButton = false;
      } else {
        showJumpButton = true;
      }
    });

    switch (listType) {
      case ListType.followed:
        if (listType == ListType.followed && authStore.isLoggedIn) getStreams();
        break;
      case ListType.top:
      case ListType.category:
        getStreams();
        break;
    }
  }

  /// Fetches the streams based on the type and current cursor.
  @action
  Future<void> getStreams() async {
    _isLoading = true;

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

    _isLoading = false;
  }

  /// Resets the cursor and then fetches the streams.
  @action
  Future<void> refreshStreams() {
    _streamsCursor = null;

    return getStreams();
  }

  void dispose() => scrollController.dispose();
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

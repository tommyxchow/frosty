import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/home/search/search_results_categories.dart';
import 'package:frosty/screens/home/search/search_results_channels.dart';
import 'package:frosty/screens/home/search/search_store.dart';
import 'package:frosty/screens/home/stream_list/streams_list.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:provider/provider.dart';

/// The search section that contians search history and search results for channels and categories.
class Search extends StatefulWidget {
  // The scroll controller for handling scroll to top functionality.
  final ScrollController scrollController;

  const Search({
    super.key,
    required this.scrollController,
  });

  @override
  State<Search> createState() => _SearchState();
}

// Constants for consistent sizing
const double _kSearchBarHeight = 80.0;

class _SearchState extends State<Search> {
  late final _searchStore = SearchStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Content behind the search bar
        Positioned.fill(
          child: Observer(
            builder: (context) {
              if (_searchStore.textEditingController.text.isEmpty) {
                if (_searchStore.searchHistory.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top +
                          _kSearchBarHeight,
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: const AlertMessage(
                      message: 'No recent searches',
                      vertical: true,
                    ),
                  );
                }

                return Scrollbar(
                  controller: widget.scrollController,
                  child: ListView(
                    controller: widget.scrollController,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top +
                          _kSearchBarHeight,
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16 + MediaQuery.of(context).padding.left,
                          right: 4 + MediaQuery.of(context).padding.right,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeader(
                              'History',
                              padding: EdgeInsets.zero,
                              isFirst: true,
                            ),
                            TextButton(
                              onPressed: _searchStore.searchHistory.clear,
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                      ..._searchStore.searchHistory.mapIndexed(
                        (index, searchTerm) => ListTile(
                          leading: const Icon(Icons.history_rounded),
                          title: Text(searchTerm),
                          onTap: () {
                            _searchStore.textEditingController.text =
                                searchTerm;
                            _searchStore.handleQuery(searchTerm);
                            _searchStore.textEditingController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                offset: _searchStore
                                    .textEditingController.text.length,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
              return CustomScrollView(
                controller: widget.scrollController,
                slivers: [
                  // Add padding for app bar and search bar
                  _SearchTopPadding(),
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) => SectionHeader(
                        'Channels',
                        isFirst: true,
                        padding: EdgeInsets.fromLTRB(
                          16 + MediaQuery.of(context).padding.left,
                          12,
                          16 + MediaQuery.of(context).padding.right,
                          8,
                        ),
                      ),
                    ),
                  ),
                  SearchResultsChannels(
                    searchStore: _searchStore,
                    query: _searchStore.searchText,
                  ),
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) => SectionHeader(
                        'Categories',
                        padding: EdgeInsets.fromLTRB(
                          16 + MediaQuery.of(context).padding.left,
                          8,
                          16 + MediaQuery.of(context).padding.right,
                          8,
                        ),
                      ),
                    ),
                  ),
                  SearchResultsCategories(searchStore: _searchStore),
                  // Add padding for bottom navigation bar
                  const SliverBottomPadding(),
                ],
              );
            },
          ),
        ),
        // Blurred search bar on top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BlurredContainer(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: MediaQuery.of(context).padding.left,
              right: MediaQuery.of(context).padding.right,
            ),
            child: Observer(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchStore.textEditingController,
                    focusNode: _searchStore.textFieldFocusNode,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Find a channel or category',
                      suffixIcon: _searchStore.textFieldFocusNode.hasFocus ||
                              _searchStore.searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              tooltip: _searchStore.searchText.isEmpty
                                  ? 'Cancel'
                                  : 'Clear',
                              onPressed: () {
                                if (_searchStore.searchText.isEmpty) {
                                  _searchStore.textFieldFocusNode.unfocus();
                                }
                                _searchStore.textEditingController.clear();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: _searchStore.handleQuery,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchStore.dispose();
    super.dispose();
  }
}

/// Helper widget for consistent top padding in search slivers
class _SearchTopPadding extends StatelessWidget {
  const _SearchTopPadding();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).padding.top + _kSearchBarHeight,
      ),
    );
  }
}

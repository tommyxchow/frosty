import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/home/search/search_results_categories.dart';
import 'package:frosty/screens/home/search/search_results_channels.dart';
import 'package:frosty/screens/home/search/search_store.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';
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

class _SearchState extends State<Search> {
  late final _searchStore = SearchStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Observer(
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
        AnimatedScrollBorder(scrollController: widget.scrollController),
        Expanded(
          child: Scrollbar(
            controller: widget.scrollController,
            child: Observer(
              builder: (context) {
                if (_searchStore.textEditingController.text.isEmpty) {
                  if (_searchStore.searchHistory.isEmpty) {
                    return const AlertMessage(message: 'No recent searches');
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 4),
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
                      Expanded(
                        child: ListView(
                          controller: widget.scrollController,
                          children: _searchStore.searchHistory
                              .mapIndexed(
                                (index, searchTerm) => ListTile(
                                  leading: const Icon(Icons.history_rounded),
                                  title: Text(searchTerm),
                                  onTap: () {
                                    _searchStore.textEditingController.text =
                                        searchTerm;
                                    _searchStore.handleQuery(searchTerm);
                                    _searchStore.textEditingController
                                        .selection = TextSelection.fromPosition(
                                      TextPosition(
                                        offset: _searchStore
                                            .textEditingController.text.length,
                                      ),
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  );
                }
                return CustomScrollView(
                  controller: widget.scrollController,
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SectionHeader(
                        'Channels',
                        isFirst: true,
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                      ),
                    ),
                    SearchResultsChannels(
                      searchStore: _searchStore,
                      query: _searchStore.searchText,
                    ),
                    const SliverToBoxAdapter(
                      child: SectionHeader(
                        'Categories',
                      ),
                    ),
                    SearchResultsCategories(searchStore: _searchStore),
                  ],
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

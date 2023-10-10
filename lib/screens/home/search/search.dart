import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/home/search/search_results_categories.dart';
import 'package:frosty/screens/home/search/search_results_channels.dart';
import 'package:frosty/screens/home/search/search_store.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/list_tile.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:provider/provider.dart';

/// The search section that contians search history and search results for channels and categories.
class Search extends StatefulWidget {
  // The scroll controller for handling scroll to top functionality.
  final ScrollController scrollController;

  const Search({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

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
    const headerPadding = EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Observer(
            builder: (context) {
              return TextField(
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
              );
            },
          ),
        ),
        Expanded(
          child: Observer(
            builder: (context) {
              if (_searchStore.textEditingController.text.isEmpty) {
                if (_searchStore.searchHistory.isEmpty) {
                  return const AlertMessage(message: 'No recent searches');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      'History',
                      padding: headerPadding,
                    ),
                    Expanded(
                      child: ListView(
                        controller: widget.scrollController,
                        children: _searchStore.searchHistory
                            .mapIndexed(
                              (index, searchTerm) => FrostyListTile(
                                leading: const Icon(Icons.history_rounded),
                                title: searchTerm,
                                trailing: Tooltip(
                                  message: 'Remove',
                                  preferBelow: false,
                                  child: IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () => _searchStore.searchHistory
                                        .removeAt(index),
                                  ),
                                ),
                                onTap: () {
                                  _searchStore.textEditingController.text =
                                      searchTerm;
                                  _searchStore.handleQuery(searchTerm);
                                  _searchStore.textEditingController.selection =
                                      TextSelection.fromPosition(TextPosition(
                                          offset: _searchStore
                                              .textEditingController
                                              .text
                                              .length));
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
                      padding: headerPadding,
                    ),
                  ),
                  SearchResultsChannels(
                    searchStore: _searchStore,
                    query: _searchStore.searchText,
                  ),
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      'Categories',
                      padding: headerPadding,
                    ),
                  ),
                  SearchResultsCategories(searchStore: _searchStore),
                ],
              );
            },
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

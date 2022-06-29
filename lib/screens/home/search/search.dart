import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/home/search/search_results_categories.dart';
import 'package:frosty/screens/home/search/search_results_channels.dart';
import 'package:frosty/screens/home/stores/search_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late final _searchStore = SearchStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
  );

  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const headerPadding = EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: TextField(
            controller: _textEditingController,
            autocorrect: false,
            decoration: InputDecoration(
              isDense: true,
              labelText: 'Find a channel or category',
              contentPadding: const EdgeInsets.all(10.0),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _textEditingController.clear();
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onSubmitted: _searchStore.handleQuery,
          ),
        ),
        Expanded(
          child: Observer(
            builder: (context) {
              if (_textEditingController.text.isEmpty || _searchStore.channelFuture == null || _searchStore.categoryFuture == null) {
                if (_searchStore.searchHistory.isEmpty) {
                  return const AlertMessage(
                    message: 'No recent searches',
                    icon: Icons.search_off,
                  );
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
                        children: _searchStore.searchHistory
                            .mapIndexed(
                              (index, searchTerm) => ListTile(
                                leading: const Icon(Icons.history),
                                title: Text(searchTerm),
                                trailing: IconButton(
                                  tooltip: 'Remove',
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () => setState(() {
                                    _searchStore.searchHistory.removeAt(index);
                                  }),
                                ),
                                onTap: () {
                                  setState(() {
                                    _textEditingController.text = searchTerm;
                                    _searchStore.handleQuery(searchTerm);
                                  });
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
                slivers: [
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      'Channels',
                      padding: headerPadding,
                    ),
                  ),
                  SearchResultsChannels(
                    searchStore: _searchStore,
                    query: _textEditingController.text,
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
    _textEditingController.dispose();
    super.dispose();
  }
}

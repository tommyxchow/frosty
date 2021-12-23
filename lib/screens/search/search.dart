import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:frosty/screens/search/search_store.dart';
import 'package:frosty/widgets/profile_picture.dart';

class Search extends StatefulWidget {
  final SearchStore searchStore;

  const Search({Key? key, required this.searchStore}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    final searchStore = widget.searchStore;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: TextField(
            controller: searchStore.textController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: searchStore.clearSearch,
                icon: const Icon(Icons.clear),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.all(10.0),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              hintText: 'Search for a channel',
            ),
            onSubmitted: searchStore.handleQuery,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => searchStore.handleQuery(searchStore.textController.text),
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Observer(
                builder: (_) {
                  if (searchStore.textController.text.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            'HISTORY',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: searchStore.searchHistory
                                .mapIndexed((index, searchTerm) => ListTile(
                                      leading: const Icon(Icons.history),
                                      title: Text(searchTerm),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.cancel),
                                        onPressed: () => searchStore.searchHistory.removeAt(index),
                                      ),
                                      onTap: () {
                                        searchStore.textController.text = searchTerm;
                                        searchStore.handleQuery(searchTerm);
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    itemCount: searchStore.searchResults.length + 1,
                    itemBuilder: (context, index) {
                      if (index == searchStore.searchResults.length) {
                        if (searchStore.textController.text.isEmpty) {
                          return const SizedBox();
                        }
                        return ListTile(
                          title: Text('Go to ${searchStore.textController.text}'),
                          onTap: () => searchStore.handleSearch(context, searchStore.textController.text),
                        );
                      }

                      final channel = searchStore.searchResults[index];
                      return ListTile(
                        title: Text(channel.displayName),
                        leading: ProfilePicture(userLogin: channel.broadcasterLogin),
                        trailing: channel.isLive
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  color: const Color(0xFFF44336),
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    'LIVE',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : null,
                        subtitle:
                            channel.isLive ? Text('Uptime: ${DateTime.now().difference(DateTime.parse(channel.startedAt)).toString().split('.')[0]}') : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return VideoChat(
                                  title: channel.title,
                                  userName: channel.displayName,
                                  userLogin: channel.broadcasterLogin,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.searchStore.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/video_chat.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/search_store.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late final SearchStore searchStore;

  @override
  void initState() {
    super.initState();
    searchStore = SearchStore(authStore: context.read<AuthStore>());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            controller: searchStore.textController,
            autocorrect: false,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              hintText: 'Search for a channel',
            ),
            onSubmitted: searchStore.handleQuery,
          ),
        ),
        Expanded(
          child: Observer(
            builder: (_) {
              return ListView.builder(
                itemCount: searchStore.searchResults.length + 1,
                itemBuilder: (context, index) {
                  if (index == searchStore.searchResults.length) {
                    if (searchStore.textController.text.isEmpty) {
                      return const SizedBox();
                    }
                    return ListTile(
                      title: Text('Go to ${searchStore.textController.text}'),
                      onTap: () => searchStore.handleSearch(searchStore.textController.text, context),
                    );
                  }

                  final channel = searchStore.searchResults[index];
                  return ListTile(
                    title: Text(channel.displayName),
                    trailing: channel.isLive
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.all(8.0),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : null,
                    subtitle: channel.isLive ? Text('Uptime: ${DateTime.now().difference(DateTime.parse(channel.startedAt)).toString().split('.')[0]}') : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return VideoChat(
                              userLogin: channel.broadcasterLogin,
                              userName: channel.displayName,
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
      ],
    );
  }

  @override
  void dispose() {
    searchStore.dispose();
    super.dispose();
  }
}
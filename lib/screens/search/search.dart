import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:frosty/screens/search/search_store.dart';

class Search extends StatefulWidget {
  final SearchStore store;

  const Search({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: TextField(
            controller: widget.store.textController,
            autocorrect: false,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              hintText: 'Search for a channel',
            ),
            onSubmitted: widget.store.handleQuery,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => widget.store.handleQuery(widget.store.textController.text),
            child: Observer(
              builder: (_) {
                return ListView.builder(
                  itemCount: widget.store.searchResults.length + 1,
                  itemBuilder: (context, index) {
                    if (index == widget.store.searchResults.length) {
                      if (widget.store.textController.text.isEmpty) {
                        return const SizedBox();
                      }
                      return ListTile(
                        title: Text('Go to ${widget.store.textController.text}'),
                        onTap: () => widget.store.handleSearch(widget.store.textController.text, context),
                      );
                    }

                    final channel = widget.store.searchResults[index];
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
      ],
    );
  }

  @override
  void dispose() {
    widget.store.dispose();
    super.dispose();
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:intl/intl.dart';

class ChattersList extends StatefulWidget {
  final ChatDetailsStore chatDetails;
  final String userLogin;

  const ChattersList({
    Key? key,
    required this.chatDetails,
    required this.userLogin,
  }) : super(key: key);

  @override
  _ChattersListState createState() => _ChattersListState();
}

class _ChattersListState extends State<ChattersList> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  var _showJumpButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 0.0 && _showJumpButton == false) setState(() => _showJumpButton = true);
      if (_scrollController.position.pixels <= 0.0 && _showJumpButton == true) setState(() => _showJumpButton = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatters = widget.chatDetails.chatUsers?.chatters;
    if (chatters != null) {
      const textStyle = TextStyle(fontWeight: FontWeight.bold);

      const headers = [
        'Broadcaster',
        'Staff',
        'Admins',
        'Global Moderators',
        'Moderators',
        'VIPs',
        'Users',
      ];

      final userTypes = [
        chatters.broadcaster,
        chatters.staff,
        chatters.admins,
        chatters.globalMods,
        chatters.moderators,
        chatters.vips,
        chatters.viewers,
      ].map((e) => e.where((user) => user.contains(_textController.text)).toList());

      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _textController,
                autocorrect: false,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Filter users',
                  contentPadding: const EdgeInsets.all(10.0),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _textController.clear()),
                    icon: const Icon(Icons.clear),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => widget.chatDetails.updateChatters(widget.userLogin),
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Users', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                const SizedBox(height: 5.0),
                                Text('${NumberFormat().format(widget.chatDetails.chatUsers?.chatterCount)} in chat'),
                              ],
                            ),
                          ),
                        ),
                        ...userTypes.expandIndexed(
                          (index, type) => [
                            if (type.isNotEmpty) ...[
                              SliverPadding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                                sliver: SliverToBoxAdapter(
                                  child: Text(
                                    headers[index],
                                    style: textStyle,
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => Text(type[index]),
                                    childCount: type.length,
                                  ),
                                ),
                              ),
                            ]
                          ],
                        )
                      ],
                    ),
                    if (_showJumpButton)
                      IconButton(
                        onPressed: () => _scrollController.jumpTo(0.0),
                        icon: const Icon(
                          Icons.arrow_circle_up,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('Failed to get chatters :('));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
}

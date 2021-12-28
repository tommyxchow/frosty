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
  final scrollController = ScrollController();
  final textController = TextEditingController();

  var showJumpButton = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels > 0.0 && showJumpButton == false) setState(() => showJumpButton = true);
      if (scrollController.position.pixels <= 0.0 && showJumpButton == true) setState(() => showJumpButton = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatters = widget.chatDetails.chatUsers?.chatters;
    if (chatters != null) {
      const textStyle = TextStyle(fontWeight: FontWeight.bold);

      const headers = [
        'Broadcaster',
        'Moderators',
        'VIPs',
        'Staff',
        'Admins',
        'Global Moderators',
        'Users',
      ];

      final userTypes = [
        chatters.broadcaster,
        chatters.moderators,
        chatters.vips,
        chatters.staff,
        chatters.admins,
        chatters.globalMods,
        chatters.viewers,
      ].map((e) => e.where((user) => user.contains(textController.text)).toList());

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: textController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () => setState(() => textController.clear()),
                  icon: const Icon(Icons.clear),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.all(10.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: 'Filter users',
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
                    controller: scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Users', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                              const SizedBox(height: 5.0),
                              Text('${NumberFormat().format(widget.chatDetails.chatUsers?.chatterCount)} users in chat'),
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
                  if (showJumpButton)
                    IconButton(
                      onPressed: () => scrollController.jumpTo(0.0),
                      icon: const Icon(
                        Icons.arrow_circle_up,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return const Center(child: Text('Failed to get chatters :('));
  }

  @override
  void dispose() {
    scrollController.dispose();
    textController.dispose();
    super.dispose();
  }
}

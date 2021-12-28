import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosty/models/chatters.dart';
import 'package:intl/intl.dart';

class ChattersList extends StatelessWidget {
  final ChatUsers? chatUsers;

  const ChattersList({Key? key, required this.chatUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatters = chatUsers?.chatters;
    if (chatters != null) {
      const headers = [
        'Moderators',
        'VIPs',
        'Staff',
        'Admins',
        'Global Moderators',
        'Users',
      ];

      final userTypes = [
        chatters.moderators,
        chatters.vips,
        chatters.staff,
        chatters.admins,
        chatters.globalMods,
        chatters.viewers,
      ];

      const textStyle = TextStyle(fontWeight: FontWeight.bold);

      return CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Users', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text(
                  '${NumberFormat().format(chatUsers?.chatterCount)} users in chat',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Broadcaster',
                  style: textStyle,
                ),
                const SizedBox(height: 5.0),
                if (chatters.broadcaster.isNotEmpty) Text(chatters.broadcaster.first),
              ],
            ),
          ),
        ),
        ...userTypes.expandIndexed((index, type) => [
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
            ])
      ]);
    }
    return const Center(child: Text('Failed to get chatters :('));
  }
}

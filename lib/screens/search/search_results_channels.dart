import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:frosty/screens/search/search_store.dart';
import 'package:frosty/widgets/profile_picture.dart';

class SearchResultsChannels extends StatelessWidget {
  final SearchStore searchStore;

  const SearchResultsChannels({Key? key, required this.searchStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> _handleSearch(BuildContext context, String search) async {
      try {
        final channelInfo = await searchStore.searchChannel(search);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoChat(
              title: channelInfo!.title,
              userName: channelInfo.broadcasterName,
              userLogin: channelInfo.broadcasterLogin,
            ),
          ),
        );
      } catch (e) {
        const snackBar = SnackBar(content: Text('Failed to get channel info :('));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        ...searchStore.channelSearchResults.map(
          (channel) => ListTile(
            title: Text(channel.displayName),
            leading: ProfilePicture(userLogin: channel.broadcasterLogin),
            trailing: channel.isLive
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      color: const Color(0xFFF44336),
                      padding: const EdgeInsets.all(10.0),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : null,
            subtitle: channel.isLive ? Text('Uptime: ${DateTime.now().difference(DateTime.parse(channel.startedAt)).toString().split('.')[0]}') : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoChat(
                  title: channel.title,
                  userName: channel.displayName,
                  userLogin: channel.broadcasterLogin,
                ),
              ),
            ),
          ),
        ),
        ListTile(
          title: Text('Go to channel "${searchStore.textController.text}"'),
          onTap: () => _handleSearch(context, searchStore.textController.text),
          trailing: Icon(Icons.adaptive.arrow_forward),
        )
      ]),
    );
  }
}

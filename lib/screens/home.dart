import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/screens/video_chat.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/channel_list_store.dart';
import 'package:frosty/stores/home_store.dart';
import 'package:frosty/widgets/drawer_menu.dart';
import 'package:provider/provider.dart';
import 'channel_list.dart';

class Home extends StatefulWidget {
  final HomeStore homeStore;
  final ChannelListStore channelListStore;

  const Home({
    Key? key,
    required this.homeStore,
    required this.channelListStore,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final titles = [if (context.read<AuthStore>().isLoggedIn) 'Followed Channels', 'Top Channels', 'Categories'];

    debugPrint('build home');
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_) {
            return widget.homeStore.search
                ? TextField(
                    controller: _textController,
                    autocorrect: false,
                    autofocus: true,
                    onSubmitted: (string) async {
                      if (await Twitch.getUser(userLogin: string, headers: context.read<AuthStore>().headersTwitch) != null) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) {
                              return VideoChat(
                                userLogin: string,
                              );
                            },
                          ),
                        );
                      } else {
                        const snackBar = SnackBar(content: Text('User does not exist :('));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      widget.homeStore.search = false;
                      _textController.clear();
                    },
                  )
                : Text(titles[widget.homeStore.selectedIndex]);
          },
        ),
        actions: [
          IconButton(
            icon: Observer(builder: (_) => widget.homeStore.search ? const Icon(Icons.cancel) : const Icon(Icons.search)),
            onPressed: () {
              widget.homeStore.search = !widget.homeStore.search;
              _textController.clear();
            },
          )
        ],
      ),
      drawer: const DrawerMenu(),
      body: Observer(
        builder: (_) {
          return IndexedStack(
            index: widget.homeStore.selectedIndex,
            children: [
              if (context.read<AuthStore>().isLoggedIn)
                ChannelList(
                  category: ChannelCategory.followed,
                  channelListStore: widget.channelListStore,
                ),
              ChannelList(
                category: ChannelCategory.top,
                channelListStore: widget.channelListStore,
              ),
              const Center(
                child: Text('Games'),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Observer(
          builder: (_) {
            return BottomNavigationBar(
              items: [
                if (context.read<AuthStore>().isLoggedIn)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Followed',
                  ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.arrow_upward),
                  label: 'Top',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.gamepad),
                  label: 'Categories',
                ),
              ],
              currentIndex: widget.homeStore.selectedIndex,
              onTap: widget.homeStore.handleTap,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

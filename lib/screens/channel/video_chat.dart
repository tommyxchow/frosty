import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';
import 'package:frosty/screens/channel/video/video.dart';
import 'package:frosty/screens/channel/video/video_store.dart';
import 'package:provider/provider.dart';

class VideoChat extends StatelessWidget {
  final String title;
  final String userName;
  final String userLogin;

  const VideoChat({
    Key? key,
    required this.title,
    required this.userName,
    required this.userLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Observer(
              builder: (_) {
                if (context.read<SettingsStore>().videoEnabled) {
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Video(
                      title: title,
                      userName: userName,
                      userLogin: userLogin,
                      videoStore: VideoStore(
                        userLogin: userLogin,
                        authStore: context.read<AuthStore>(),
                      ),
                    ),
                  );
                }
                return AppBar(
                  title: Text(
                    userName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Settings(settingsStore: context.read<SettingsStore>());
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: Chat(
                chatStore: ChatStore(
                  auth: context.read<AuthStore>(),
                  settings: context.read<SettingsStore>(),
                  channelName: userLogin,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

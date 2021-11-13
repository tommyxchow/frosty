import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/stores/chat_store.dart';
import 'package:frosty/stores/settings_store.dart';
import 'package:frosty/stores/video_store.dart';
import 'package:frosty/widgets/chat.dart';
import 'package:frosty/widgets/video.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VideoChat extends StatelessWidget {
  final String userLogin;
  final String userName;

  const VideoChat({Key? key, required this.userLogin, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              Observer(
                builder: (_) {
                  if (context.read<SettingsStore>().videoEnabled) {
                    return AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Video(
                        channelName: userLogin,
                        videoStore: VideoStore(),
                        settingsStore: context.read<SettingsStore>(),
                      ),
                    );
                  }
                  return AppBar(
                    title: Text(
                      userName,
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
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
                    channelName: userLogin,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

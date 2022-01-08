import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/section_header.dart';

class ChatSettings extends StatefulWidget {
  final SettingsStore settingsStore;

  const ChatSettings({Key? key, required this.settingsStore}) : super(key: key);

  @override
  _ChatSettingsState createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  var showPreview = false;

  @override
  Widget build(BuildContext context) {
    final settingsStore = widget.settingsStore;

    return Observer(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('Chat'),
            SwitchListTile.adaptive(
              title: const Text('Show deleted messages'),
              value: settingsStore.showDeletedMessages,
              onChanged: (newValue) => settingsStore.showDeletedMessages = newValue,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Show zero-width emotes'),
              subtitle: const Text('Makes "stacked" emotes from BetterTTV and 7TV visible in chat messages.'),
              value: settingsStore.showZeroWidth,
              onChanged: (newValue) => settingsStore.showZeroWidth = newValue,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Show message timestamps'),
              subtitle: const Text('Displays timestamps for when a chat message was sent.'),
              value: settingsStore.showTimestamps,
              onChanged: (newValue) => settingsStore.showTimestamps = newValue,
            ),
            SwitchListTile.adaptive(
              title: const Text('Use 12-hour timestamps'),
              value: settingsStore.useTwelveHourTimestamps,
              onChanged: settingsStore.showTimestamps ? (newValue) => settingsStore.useTwelveHourTimestamps = newValue : null,
            ),
            SwitchListTile.adaptive(
              isThreeLine: true,
              title: const Text('Use readable colors for chat names'),
              subtitle: const Text('Makes dark names in chat readable by boosting their lightness value.'),
              value: settingsStore.useReadableColors,
              onChanged: (newValue) => settingsStore.useReadableColors = newValue,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: showPreview
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      margin: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purpleAccent),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(children: [
                              const TextSpan(text: 'Hello! This is a text preview message '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: CachedNetworkImage(
                                  imageUrl: 'https://static-cdn.jtvnw.net/emoticons/v2/425618/default/dark/3.0',
                                  placeholder: (context, url) => const SizedBox(),
                                  height: 30.0,
                                ),
                              )
                            ]),
                            textScaleFactor: settingsStore.fontScale,
                          ),
                          SizedBox(height: settingsStore.messageSpacing),
                          Text(
                            'Here is a another message to visualize spacing!',
                            textScaleFactor: settingsStore.fontScale,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
            ListTile(
              isThreeLine: true,
              title: Text('Message scale: ${settingsStore.fontScale.toStringAsFixed(1)}x'),
              subtitle: Slider.adaptive(
                value: settingsStore.fontScale,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (newValue) => settingsStore.fontScale = newValue,
              ),
            ),
            ListTile(
              title: Text('Message spacing: ${settingsStore.messageSpacing.toStringAsFixed(0)}'),
              subtitle: Slider.adaptive(
                value: settingsStore.messageSpacing,
                min: 0.0,
                max: 30.0,
                divisions: 30,
                onChanged: (newValue) => settingsStore.messageSpacing = newValue,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => showPreview = !showPreview),
                child: Text(showPreview ? 'Hide Text Preview' : 'Show Text Preview'),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants/constants.dart';
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
    const timestamps = ['Disabled', '12-Hour', '24-Hour'];

    final settingsStore = widget.settingsStore;

    return Observer(
      builder: (context) => ExpansionTile(
        leading: const Icon(Icons.chat),
        title: const Text(
          'Chat',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          SwitchListTile.adaptive(
            title: const Text('Show bottom bar'),
            value: settingsStore.showBottomBar,
            onChanged: (newValue) => settingsStore.showBottomBar = newValue,
          ),
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
            title: const Text('Show message dividers'),
            subtitle: const Text('Displays a subtle divider between each chat message.'),
            value: settingsStore.showChatMessageDividers,
            onChanged: (newValue) => settingsStore.showChatMessageDividers = newValue,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Use readable colors for chat names'),
            subtitle: const Text('Adjusts the lightness value of overly bright/dark names in chat.'),
            value: settingsStore.useReadableColors,
            onChanged: (newValue) => settingsStore.useReadableColors = newValue,
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('Message timestamps'),
            subtitle: const Text('Displays timestamps for when a chat message was sent.'),
            trailing: DropdownButton(
              value: settingsStore.timestampType,
              onChanged: (TimestampType? newTimestamp) => settingsStore.timestampType = newTimestamp!,
              items: TimestampType.values
                  .map((TimestampType value) => DropdownMenuItem(
                        value: value,
                        child: Text(timestamps[value.index]),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10.0),
          const SectionHeader('Message Appearance'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurple),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: settingsStore.fontSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: CachedNetworkImage(
                            imageUrl: 'https://static-cdn.jtvnw.net/badges/v1/bbbe0db0-a598-423e-86d0-f9fb98ca1933/3',
                            height: defaultBadgeSize * settingsStore.badgeScale,
                            width: defaultBadgeSize * settingsStore.badgeScale,
                          ),
                        ),
                        const TextSpan(text: ' Badge and emote preview '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: CachedNetworkImage(
                            imageUrl: 'https://static-cdn.jtvnw.net/emoticons/v2/425618/default/dark/3.0',
                            height: defaultEmoteSize * settingsStore.emoteScale,
                            width: defaultEmoteSize * settingsStore.emoteScale,
                          ),
                        ),
                      ],
                    ),
                    textScaleFactor: settingsStore.messageScale,
                  ),
                  SizedBox(height: settingsStore.messageSpacing),
                  Text(
                    'Hello! Here\'s a text preview.',
                    textScaleFactor: settingsStore.messageScale,
                  ),
                  SizedBox(height: settingsStore.messageSpacing),
                  Text(
                    'And another for spacing without an emote!',
                    textScaleFactor: settingsStore.messageScale,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Message scale'),
                const Spacer(),
                Text('${settingsStore.messageScale.toStringAsFixed(2)}x'),
              ],
            ),
            subtitle: Slider.adaptive(
              value: settingsStore.messageScale,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              onChanged: (newValue) => settingsStore.messageScale = newValue,
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Message spacing'),
                const Spacer(),
                Text(settingsStore.messageSpacing.toStringAsFixed(0).toString()),
              ],
            ),
            subtitle: Slider.adaptive(
              value: settingsStore.messageSpacing,
              min: 0.0,
              max: 30.0,
              divisions: 6,
              onChanged: (newValue) => settingsStore.messageSpacing = newValue,
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Font size'),
                const Spacer(),
                Text(settingsStore.fontSize.toInt().toString()),
              ],
            ),
            subtitle: Slider.adaptive(
              value: settingsStore.fontSize,
              min: 5,
              max: 20,
              divisions: 15,
              onChanged: (newValue) => settingsStore.fontSize = newValue,
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Badge scale'),
                const Spacer(),
                Text('${settingsStore.badgeScale.toStringAsFixed(2)}x'),
              ],
            ),
            subtitle: Slider.adaptive(
              value: settingsStore.badgeScale,
              min: 0.25,
              max: 3.0,
              divisions: 11,
              onChanged: (newValue) => settingsStore.badgeScale = newValue,
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Emote scale'),
                const Spacer(),
                Text('${settingsStore.emoteScale.toStringAsFixed(2)}x'),
              ],
            ),
            subtitle: Slider.adaptive(
              value: settingsStore.emoteScale,
              min: 0.25,
              max: 3.0,
              divisions: 11,
              onChanged: (newValue) => settingsStore.emoteScale = newValue,
            ),
          ),
        ],
      ),
    );
  }
}

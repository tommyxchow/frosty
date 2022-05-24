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
  State<ChatSettings> createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  var showPreview = false;

  @override
  Widget build(BuildContext context) {
    const timestamps = ['Disabled', '12-Hour', '24-Hour'];

    const sectionPadding = EdgeInsets.only(left: 15.0, bottom: 5.0, top: 20.0);

    final settingsStore = widget.settingsStore;

    return Observer(
      builder: (context) => ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: const Icon(Icons.chat),
        title: const Text(
          'Chat',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          const SectionHeader(
            'Layout',
            padding: sectionPadding,
          ),
          SwitchListTile.adaptive(
            title: const Text('Bottom Bar'),
            value: settingsStore.showBottomBar,
            onChanged: (newValue) => settingsStore.showBottomBar = newValue,
          ),
          SwitchListTile.adaptive(
            title: const Text('Landscape Chat on Left Side'),
            value: settingsStore.landscapeChatLeftSide,
            onChanged: (newValue) => settingsStore.landscapeChatLeftSide = newValue,
          ),
          const SizedBox(height: 15.0),
          ListTile(
            title: Row(
              children: [
                const Text('Landscape Chat Width'),
                const Spacer(),
                Text('${(settingsStore.landscapeChatWidth * 100).toInt()}%'),
              ],
            ),
            subtitle: Slider.adaptive(
              value: settingsStore.landscapeChatWidth,
              min: 0.2,
              max: 0.8,
              divisions: 12,
              onChanged: (newValue) => settingsStore.landscapeChatWidth = newValue,
            ),
          ),
          const SectionHeader(
            'Emotes',
            padding: sectionPadding,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Emote Autocomplete'),
            subtitle: const Text('Shows a bar that suggests matching emotes when typing.'),
            value: settingsStore.emoteAutocomplete,
            onChanged: settingsStore.showBottomBar ? (newValue) => settingsStore.emoteAutocomplete = newValue : null,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Zero-Width Emotes'),
            subtitle: const Text('Shows "stacked" emotes from BetterTTV and 7TV.'),
            value: settingsStore.showZeroWidth,
            onChanged: (newValue) => settingsStore.showZeroWidth = newValue,
          ),
          const SectionHeader(
            'Message Appearance',
            padding: sectionPadding,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Readable Name Colors'),
            subtitle: const Text('Adjusts the lightness value of overly bright or dark names.'),
            value: settingsStore.useReadableColors,
            onChanged: (newValue) => settingsStore.useReadableColors = newValue,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Show Deleted Messages'),
            subtitle: const Text('Restores the original message of deleted messages.'),
            value: settingsStore.showDeletedMessages,
            onChanged: (newValue) => settingsStore.showDeletedMessages = newValue,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Message Dividers'),
            subtitle: const Text('Shows a subtle divider between each message.'),
            value: settingsStore.showChatMessageDividers,
            onChanged: (newValue) => settingsStore.showChatMessageDividers = newValue,
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('Message Timestamps'),
            subtitle: const Text('Shows timestamps for when a message was sent.'),
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
          const SectionHeader(
            'Message Sizing',
            padding: sectionPadding,
          ),
          ExpansionTile(
            title: const Text('Preview'),
            children: [
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
                            const TextSpan(text: ' Badge and emote preview. '),
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
            ],
          ),
          const SizedBox(height: 10.0),
          ListTile(
            title: Row(
              children: [
                const Text('Badge Scale'),
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
                const Text('Emote Scale'),
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
          ListTile(
            title: Row(
              children: [
                const Text('Message Scale'),
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
                const Text('Message Spacing'),
                const Spacer(),
                Text(settingsStore.messageSpacing.toStringAsFixed(0).toString()),
              ],
            ),
            subtitle: Slider.adaptive(
              value: settingsStore.messageSpacing,
              min: 0.0,
              max: 20.0,
              divisions: 6,
              onChanged: (newValue) => settingsStore.messageSpacing = newValue,
            ),
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Font Size'),
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
        ],
      ),
    );
  }
}

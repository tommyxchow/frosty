import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
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
    const landscapeCutouts = ['None', 'Left', 'Right', 'Both'];

    const timestamps = ['Disabled', '12-hour', '24-hour'];

    const sectionPadding = EdgeInsets.only(left: 16.0, bottom: 5.0, top: 30.0);

    final settingsStore = widget.settingsStore;

    return Observer(
      builder: (context) => ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.symmetric(vertical: 10.0),
        leading: const Icon(Icons.chat),
        title: const Text(
          'Chat',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          ListTile(
            title: Row(
              children: [
                const Text('Message delay'),
                const Spacer(),
                Text('${settingsStore.chatDelay.toInt()} ${settingsStore.chatDelay == 1.0 ? 'second' : 'seconds'}'),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider.adaptive(
                  value: settingsStore.chatDelay,
                  min: 0.0,
                  max: 30.0,
                  divisions: 30,
                  onChanged: (newValue) => settingsStore.chatDelay = newValue,
                ),
                Text('Adds a delay before each message is rendered in chat. ${Platform.isIOS ? '15 seconds is recommended for iOS.' : ''}'),
                const SizedBox(height: 15),
              ],
            ),
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Prevent sleep in chat-only mode'),
            subtitle: const Text('Requires restarting the chat in order to take effect.'),
            value: settingsStore.chatOnlyPreventSleep,
            onChanged: !settingsStore.showVideo ? (newValue) => settingsStore.chatOnlyPreventSleep = newValue : null,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Autocomplete'),
            subtitle: const Text('Shows a bar that suggests matching emotes and mentions while typing.'),
            value: settingsStore.autocomplete,
            onChanged: settingsStore.showBottomBar ? (newValue) => settingsStore.autocomplete = newValue : null,
          ),
          const SectionHeader(
            'Layout',
            padding: sectionPadding,
            showDivider: true,
          ),
          SwitchListTile.adaptive(
            title: const Text('Bottom bar'),
            value: settingsStore.showBottomBar,
            onChanged: (newValue) => settingsStore.showBottomBar = newValue,
          ),
          SwitchListTile.adaptive(
            title: const Text('Landscape chat on left side'),
            value: settingsStore.landscapeChatLeftSide,
            onChanged: (newValue) => settingsStore.landscapeChatLeftSide = newValue,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Notifications on bottom'),
            subtitle: const Text('Shows notifications (e.g., "Message copied") on the bottom of the chat.'),
            value: settingsStore.chatNotificationsOnBottom,
            onChanged: (newValue) => settingsStore.chatNotificationsOnBottom = newValue,
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('Landscape fill cutout side'),
            subtitle: const Text('Overrides and fills the available space in the display cutout/notch.'),
            trailing: DropdownButton(
              value: settingsStore.landscapeCutout,
              onChanged: (LandscapeCutoutType? newValue) => settingsStore.landscapeCutout = newValue!,
              items: LandscapeCutoutType.values
                  .map((LandscapeCutoutType value) => DropdownMenuItem(
                        value: value,
                        child: Text(landscapeCutouts[value.index]),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 15.0),
          ListTile(
            title: Row(
              children: [
                const Text('Chat width'),
                const Spacer(),
                Text('${(settingsStore.chatWidth * 100).toStringAsFixed(0)}%'),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider.adaptive(
                  value: settingsStore.chatWidth,
                  min: 0.2,
                  max: 0.6,
                  divisions: 8,
                  onChanged: (newValue) => settingsStore.chatWidth = newValue,
                ),
                const Text('Sets the width of the chat in fullscreen and theater mode.'),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SizedBox(height: 15.0),
          ListTile(
            title: Row(
              children: [
                const Text('Chat overlay opacity'),
                const Spacer(),
                Text('${(settingsStore.fullScreenChatOverlayOpacity * 100).toStringAsFixed(0)}%'),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider.adaptive(
                  value: settingsStore.fullScreenChatOverlayOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (newValue) => settingsStore.fullScreenChatOverlayOpacity = newValue,
                ),
                const Text('Sets the opacity (transparency) of the overlay chat in fullscreen mode.'),
                const SizedBox(height: 15),
              ],
            ),
          ),
          const SectionHeader(
            'Emotes',
            padding: sectionPadding,
            showDivider: true,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Zero-width emotes'),
            subtitle: const Text('Shows "stacked" emotes from BetterTTV and 7TV.'),
            value: settingsStore.showZeroWidth,
            onChanged: (newValue) => settingsStore.showZeroWidth = newValue,
          ),
          const SectionHeader(
            'Message Appearance',
            padding: sectionPadding,
            showDivider: true,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Readable name colors'),
            subtitle: const Text('Adjusts the lightness value of overly bright or dark names.'),
            value: settingsStore.useReadableColors,
            onChanged: (newValue) => settingsStore.useReadableColors = newValue,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Show deleted messages'),
            subtitle: const Text('Restores the original message of deleted messages.'),
            value: settingsStore.showDeletedMessages,
            onChanged: (newValue) => settingsStore.showDeletedMessages = newValue,
          ),
          SwitchListTile.adaptive(
            isThreeLine: true,
            title: const Text('Message dividers'),
            subtitle: const Text('Shows a subtle divider between each message.'),
            value: settingsStore.showChatMessageDividers,
            onChanged: (newValue) => settingsStore.showChatMessageDividers = newValue,
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('Message timestamps'),
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
            showDivider: true,
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
        ],
      ),
    );
  }
}

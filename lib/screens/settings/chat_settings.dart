import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_slider.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/screens/settings/widgets/settings_muted_words.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatSettings extends StatefulWidget {
  final SettingsStore settingsStore;

  const ChatSettings({super.key, required this.settingsStore});

  @override
  State<ChatSettings> createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  var showPreview = false;

  @override
  Widget build(BuildContext context) {
    final settingsStore = widget.settingsStore;

    return Observer(
      builder: (context) => ListView(
        padding: const EdgeInsets.only(top: 16),
        children: [
          const SectionHeader(
            'Message sizing',
            isFirst: true,
          ),
          ExpansionTile(
            title: const Text(
              'Preview',
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: DefaultTextStyle(
                  style: DefaultTextStyle.of(context)
                      .style
                      .copyWith(fontSize: settingsStore.fontSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: FrostyCachedNetworkImage(
                                imageUrl:
                                    'https://static-cdn.jtvnw.net/badges/v1/bbbe0db0-a598-423e-86d0-f9fb98ca1933/3',
                                height:
                                    defaultBadgeSize * settingsStore.badgeScale,
                                width:
                                    defaultBadgeSize * settingsStore.badgeScale,
                              ),
                            ),
                            const TextSpan(text: ' Badge and emote preview. '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: FrostyCachedNetworkImage(
                                imageUrl:
                                    'https://static-cdn.jtvnw.net/emoticons/v2/425618/default/dark/3.0',
                                height:
                                    defaultEmoteSize * settingsStore.emoteScale,
                                width:
                                    defaultEmoteSize * settingsStore.emoteScale,
                              ),
                            ),
                          ],
                        ),
                        textScaler:
                            TextScaler.linear(settingsStore.messageScale),
                      ),
                      SizedBox(height: settingsStore.messageSpacing),
                      Text(
                        'Hello! Here\'s a text preview.',
                        textScaler:
                            TextScaler.linear(settingsStore.messageScale),
                      ),
                      SizedBox(height: settingsStore.messageSpacing),
                      Text(
                        'And another for spacing without an emote!',
                        textScaler:
                            TextScaler.linear(settingsStore.messageScale),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SettingsListSlider(
            title: 'Badge scale',
            trailing: '${settingsStore.badgeScale.toStringAsFixed(2)}x',
            value: settingsStore.badgeScale,
            min: 0.25,
            max: 3.0,
            divisions: 11,
            onChanged: (newValue) => settingsStore.badgeScale = newValue,
          ),
          SettingsListSlider(
            title: 'Emote scale',
            trailing: '${settingsStore.emoteScale.toStringAsFixed(2)}x',
            value: settingsStore.emoteScale,
            min: 0.25,
            max: 3.0,
            divisions: 11,
            onChanged: (newValue) => settingsStore.emoteScale = newValue,
          ),
          SettingsListSlider(
            title: 'Message scale',
            trailing: '${settingsStore.messageScale.toStringAsFixed(2)}x',
            value: settingsStore.messageScale,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            onChanged: (newValue) => settingsStore.messageScale = newValue,
          ),
          SettingsListSlider(
            title: 'Message spacing',
            trailing: '${settingsStore.messageSpacing.toStringAsFixed(0)}px',
            value: settingsStore.messageSpacing,
            max: 30.0,
            divisions: 15,
            onChanged: (newValue) => settingsStore.messageSpacing = newValue,
          ),
          SettingsListSlider(
            title: 'Font size',
            trailing: settingsStore.fontSize.toInt().toString(),
            value: settingsStore.fontSize,
            min: 5,
            max: 20,
            divisions: 15,
            onChanged: (newValue) => settingsStore.fontSize = newValue,
          ),
          const SectionHeader('Message appearance'),
          SettingsListSwitch(
            title: 'Use readable name colors',
            subtitle: const Text(
              'Adjusts the lightness value of overly bright and dark names.',
            ),
            value: settingsStore.useReadableColors,
            onChanged: (newValue) => settingsStore.useReadableColors = newValue,
          ),
          SettingsListSwitch(
            title: 'Show deleted messages',
            subtitle: const Text(
              'Restores the original message of deleted messages.',
            ),
            value: settingsStore.showDeletedMessages,
            onChanged: (newValue) =>
                settingsStore.showDeletedMessages = newValue,
          ),
          SettingsListSwitch(
            title: 'Show message dividers',
            value: settingsStore.showChatMessageDividers,
            onChanged: (newValue) =>
                settingsStore.showChatMessageDividers = newValue,
          ),
          SettingsListSelect(
            title: 'Message timestamps',
            selectedOption: timestampNames[settingsStore.timestampType.index],
            options: timestampNames,
            onChanged: (newValue) => settingsStore.timestampType =
                TimestampType.values[timestampNames.indexOf(newValue)],
          ),
          const SectionHeader('Delay and latency'),
          SettingsListSwitch(
            title: 'Sync message delay with stream latency (experimental)',
            value: settingsStore.autoSyncChatDelay,
            onChanged: (newValue) => settingsStore.autoSyncChatDelay = newValue,
          ),
          if (!settingsStore.autoSyncChatDelay)
            SettingsListSlider(
              title: 'Message delay',
              trailing: '${settingsStore.chatDelay.toInt()} seconds',
              subtitle:
                  'Adds a delay before each message is rendered in chat. ${Platform.isIOS ? '15 seconds is recommended for iOS.' : ''}',
              value: settingsStore.chatDelay,
              max: 30.0,
              divisions: 30,
              onChanged: (newValue) => settingsStore.chatDelay = newValue,
            ),
          const SectionHeader('Alerts'),
          SettingsListSwitch(
            title: 'Highlight first time chatters',
            value: settingsStore.highlightFirstTimeChatter,
            onChanged: (newValue) =>
                settingsStore.highlightFirstTimeChatter = newValue,
          ),
          SettingsListSwitch(
            title: 'Show notices',
            subtitle: const Text(
              'Shows notices such as subs and re-subs, announcements, and raids.',
            ),
            value: settingsStore.showUserNotices,
            onChanged: (newValue) => settingsStore.showUserNotices = newValue,
          ),
          const SectionHeader('Layout'),
          SettingsListSwitch(
            title: 'Show bottom bar',
            value: settingsStore.showBottomBar,
            onChanged: (newValue) => settingsStore.showBottomBar = newValue,
          ),
          SettingsListSwitch(
            title: 'Move emote menu button left',
            subtitle: const Text(
              'Places the emote menu button on the left side to avoid accidental presses.',
            ),
            value: settingsStore.emoteMenuButtonOnLeft,
            onChanged: (newValue) =>
                settingsStore.emoteMenuButtonOnLeft = newValue,
          ),
          SettingsListSwitch(
            title: 'Move notifications to bottom',
            value: settingsStore.chatNotificationsOnBottom,
            onChanged: (newValue) =>
                settingsStore.chatNotificationsOnBottom = newValue,
          ),
          const SectionHeader('Landscape mode'),
          SettingsListSwitch(
            title: 'Move chat left',
            value: settingsStore.landscapeChatLeftSide,
            onChanged: (newValue) =>
                settingsStore.landscapeChatLeftSide = newValue,
          ),
          SettingsListSwitch(
            title: 'Force vertical chat',
            subtitle:
                const Text('Intended for tablets and other larger displays.'),
            value: settingsStore.landscapeForceVerticalChat,
            onChanged: (newValue) =>
                settingsStore.landscapeForceVerticalChat = newValue,
          ),
          SettingsListSelect(
            title: 'Fill notch side',
            subtitle:
                'Overrides and fills the available space in devices with a display notch.',
            selectedOption:
                landscapeCutoutNames[settingsStore.landscapeCutout.index],
            options: landscapeCutoutNames,
            onChanged: (newValue) => settingsStore.landscapeCutout =
                LandscapeCutoutType
                    .values[landscapeCutoutNames.indexOf(newValue)],
          ),
          SettingsListSlider(
            title: 'Chat width',
            trailing: '${(settingsStore.chatWidth * 100).toStringAsFixed(0)}%',
            value: settingsStore.chatWidth,
            min: 0.2,
            max: 0.6,
            divisions: 8,
            onChanged: (newValue) => settingsStore.chatWidth = newValue,
          ),
          SettingsListSlider(
            title: 'Chat overlay opacity',
            trailing:
                '${(settingsStore.fullScreenChatOverlayOpacity * 100).toStringAsFixed(0)}%',
            subtitle:
                'Sets the opacity (transparency) of the overlay chat in fullscreen mode.',
            value: settingsStore.fullScreenChatOverlayOpacity,
            divisions: 10,
            onChanged: (newValue) =>
                settingsStore.fullScreenChatOverlayOpacity = newValue,
          ),
          const SectionHeader('Sleep'),
          SettingsListSwitch(
            title: 'Prevent sleep in chat-only mode',
            subtitle: const Text(
              'Requires restarting the chat in order to take effect.',
            ),
            value: settingsStore.chatOnlyPreventSleep,
            onChanged: (newValue) =>
                settingsStore.chatOnlyPreventSleep = newValue,
          ),
          const SectionHeader('Muted keywords'),
          SettingsMutedWords(settingsStore: settingsStore),
          SettingsListSwitch(
            title: 'Match whole words',
            subtitle: const Text(
              'Only matches whole words instead of partial matches.',
            ),
            value: settingsStore.matchWholeWord,
            onChanged: (newValue) => settingsStore.matchWholeWord = newValue,
          ),
          const SectionHeader('Autocomplete'),
          SettingsListSwitch(
            title: 'Show autocomplete bar',
            subtitle: const Text(
              'Shows a bar containing matching emotes and mentions while typing.',
            ),
            value: settingsStore.autocomplete,
            onChanged: (newValue) => settingsStore.autocomplete = newValue,
          ),
          const SectionHeader('Emotes and badges'),
          SettingsListSwitch(
            title: 'Show Twitch emotes',
            value: settingsStore.showTwitchEmotes,
            onChanged: (newValue) => settingsStore.showTwitchEmotes = newValue,
          ),
          SettingsListSwitch(
            title: 'Show Twitch badges',
            value: settingsStore.showTwitchBadges,
            onChanged: (newValue) => settingsStore.showTwitchBadges = newValue,
          ),
          SettingsListSwitch(
            title: 'Show 7TV emotes',
            value: settingsStore.show7TVEmotes,
            onChanged: (newValue) => settingsStore.show7TVEmotes = newValue,
          ),
          SettingsListSwitch(
            title: 'Show BTTV emotes',
            value: settingsStore.showBTTVEmotes,
            onChanged: (newValue) => settingsStore.showBTTVEmotes = newValue,
          ),
          SettingsListSwitch(
            title: 'Show BTTV badges',
            value: settingsStore.showBTTVBadges,
            onChanged: (newValue) => settingsStore.showBTTVBadges = newValue,
          ),
          SettingsListSwitch(
            title: 'Show FFZ emotes',
            value: settingsStore.showFFZEmotes,
            onChanged: (newValue) => settingsStore.showFFZEmotes = newValue,
          ),
          SettingsListSwitch(
            title: 'Show FFZ badges',
            value: settingsStore.showFFZBadges,
            onChanged: (newValue) => settingsStore.showFFZBadges = newValue,
          ),
          const SectionHeader('Recent messages'),
          SettingsListSwitch(
            title: 'Show historical recent messages',
            subtitle: Text.rich(
              TextSpan(
                text:
                    'Loads historical recent messages in chat through a third-party API service at ',
                children: [
                  TextSpan(
                    text: 'https://recent-messages.robotty.de/',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(
                            Uri.parse(
                              'https://recent-messages.robotty.de/',
                            ),
                            mode: settingsStore.launchUrlExternal
                                ? LaunchMode.externalApplication
                                : LaunchMode.inAppBrowserView,
                          ),
                  ),
                ],
              ),
            ),
            value: settingsStore.showRecentMessages,
            onChanged: (newValue) =>
                settingsStore.showRecentMessages = newValue,
          ),
        ],
      ),
    );
  }
}

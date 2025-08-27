import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:frosty/widgets/section_header.dart';

class GeneralSettings extends StatefulWidget {
  final SettingsStore settingsStore;

  const GeneralSettings({super.key, required this.settingsStore});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: 116,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            children: [
              const SectionHeader(
                'Theme',
                isFirst: true,
              ),
              SettingsListSelect(
                selectedOption:
                    themeNames[widget.settingsStore.themeType.index],
                options: themeNames,
                onChanged: (newTheme) => widget.settingsStore.themeType =
                    ThemeType.values[themeNames.indexOf(newTheme)],
              ),
              ListTile(
                title: const Text('Accent color'),
                trailing: IconButton(
                  icon: DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Color(widget.settingsStore.accentColor),
                      radius: 16,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => FrostyDialog(
                        title: 'Accent color',
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor:
                                Color(widget.settingsStore.accentColor),
                            onColorChanged: (newColor) => widget.settingsStore
                                .accentColor = newColor.toARGB32(),
                            enableAlpha: false,
                            pickerAreaBorderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            labelTypes: const [],
                          ),
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SectionHeader('Stream card'),
              SettingsListSwitch(
                title: 'Use large stream card',
                value: widget.settingsStore.largeStreamCard,
                onChanged: (newValue) =>
                    widget.settingsStore.largeStreamCard = newValue,
              ),
              SettingsListSwitch(
                title: 'Show thumbnail',
                value: widget.settingsStore.showThumbnails,
                onChanged: (newValue) =>
                    widget.settingsStore.showThumbnails = newValue,
              ),
              SettingsListSwitch(
                title: 'Show offline pinned channels',
                subtitle: const Text('Display offline channels in the pinned section'),
                value: widget.settingsStore.showOfflinePinnedChannels,
                onChanged: (newValue) =>
                    widget.settingsStore.showOfflinePinnedChannels = newValue,
              ),
              const SectionHeader('Links'),
              SettingsListSwitch(
                title: 'Open links in external browser',
                value: widget.settingsStore.launchUrlExternal,
                onChanged: (newValue) =>
                    widget.settingsStore.launchUrlExternal = newValue,
              ),
            ],
          ),
          Positioned(
            top: 108,
            left: 0,
            right: 0,
            child: AnimatedScrollBorder(
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';

class SettingsMutedWords extends StatefulWidget {
  final SettingsStore settingsStore;
  const SettingsMutedWords({super.key, required this.settingsStore});

  @override
  State<SettingsMutedWords> createState() => _SettingsMutedWordsState();
}

class _SettingsMutedWordsState extends State<SettingsMutedWords> {
  late final SettingsStore settingsStore;
  final TextEditingController textController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();

  @override
  void initState() {
    settingsStore = widget.settingsStore;
    super.initState();
  }

  void addMutedWord(String text) {
    settingsStore.mutedWords = [
      ...settingsStore.mutedWords,
      text,
    ];

    textController.clear();
    textFieldFocusNode.unfocus();
  }

  void removeMutedWord(int index) {
    settingsStore.mutedWords = [
      ...settingsStore.mutedWords..removeAt(index),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: const Icon(Icons.edit),
      title: const Text('Muted keywords'),
      onTap: () => showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Observer(
            builder: (context) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: TextField(
                      controller: textController,
                      focusNode: textFieldFocusNode,
                      onChanged: (value) {
                        textController.text = value;
                      },
                      onSubmitted: (value) {
                        addMutedWord(value);
                      },
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Enter keywords to mute',
                        suffixIcon: IconButton(
                          tooltip: textController.text.isEmpty
                              ? 'Cancel'
                              : 'Add keyword',
                          onPressed: () {
                            if (textController.text.isEmpty) {
                              textFieldFocusNode.unfocus();
                            } else {
                              addMutedWord(
                                textController.text,
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                        ),
                      ),
                    ),
                  ),
                  if (settingsStore.mutedWords.isEmpty)
                    const Expanded(
                      child: AlertMessage(
                        message: 'No muted keywords',
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: settingsStore.mutedWords.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title:
                              Text(settingsStore.mutedWords.elementAt(index)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // show confirmation dialog before deleting a keyword
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete keyword'),
                                  content: const Text(
                                    'Are you sure you want to delete this keyword?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        removeMutedWord(index);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }
}

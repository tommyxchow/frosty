import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';

class SettingsMutedWords extends StatelessWidget {
  final SettingsStore settingsStore;
  const SettingsMutedWords({super.key, required this.settingsStore});

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
                      controller: settingsStore.textController,
                      focusNode: settingsStore.textFieldFocusNode,
                      onChanged: (value) {
                        settingsStore.textController.text = value;
                      },
                      onSubmitted: (value) {
                        settingsStore.addMutedWord(value);
                      },
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'Enter keywords to mute',
                        suffixIcon: settingsStore.textControllerTextIsEmpty
                            ? IconButton(
                                tooltip:
                                    settingsStore.textController.text.isEmpty
                                        ? 'Cancel'
                                        : 'Add keyword',
                                onPressed: () {
                                  if (settingsStore
                                      .textController.text.isEmpty) {
                                    settingsStore.textFieldFocusNode.unfocus();
                                  } else {
                                    settingsStore.addMutedWord(
                                      settingsStore.textController.text,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.check),
                              )
                            : null,
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
                                        settingsStore.removeMutedWord(index);
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
}

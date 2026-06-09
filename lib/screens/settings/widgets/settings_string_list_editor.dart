import 'package:flutter/material.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/frosty_scrollbar.dart';

class SettingsStringListEditor extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String emptyMessage;
  final String hintText;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String? Function(String value) validator;
  final String Function(String value) normalizeValue;

  const SettingsStringListEditor({
    super.key,
    required this.title,
    this.subtitle,
    required this.emptyMessage,
    required this.hintText,
    required this.values,
    required this.onChanged,
    required this.validator,
    this.normalizeValue = _trimValue,
  });

  static String _trimValue(String value) => value.trim();

  @override
  State<SettingsStringListEditor> createState() =>
      _SettingsStringListEditorState();
}

class _SettingsStringListEditorState extends State<SettingsStringListEditor> {
  final TextEditingController textController = TextEditingController();
  final FocusNode textFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.subtitle;

    return ListTile(
      trailing: const Icon(Icons.edit),
      title: Text(widget.title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: () => _showEditor(context),
    );
  }

  void _showEditor(BuildContext context) {
    var values = [...widget.values];
    String? errorText;

    textController.clear();

    showModalBottomSheetWithProperFocus(
      isScrollControlled: true,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          void addValue() {
            final rawValue = textController.text;
            final error = widget.validator(rawValue);

            if (error != null) {
              setModalState(() => errorText = error);
              return;
            }

            final value = widget.normalizeValue(rawValue);
            if (values.contains(value)) {
              setModalState(() => errorText = 'This entry is already saved');
              return;
            }

            setModalState(() {
              values = [...values, value];
              errorText = null;
            });
            widget.onChanged(values);
            textController.clear();
            textFieldFocusNode.unfocus();
          }

          void removeValue(int index) {
            final removed = values.elementAt(index);
            setModalState(() {
              values = [...values..removeAt(index)];
            });
            widget.onChanged(values);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Removed '$removed'"),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    setModalState(() {
                      values = [...values, removed];
                    });
                    widget.onChanged(values);
                  },
                ),
              ),
            );
          }

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: TextField(
                    controller: textController,
                    focusNode: textFieldFocusNode,
                    onChanged: (_) {
                      if (errorText != null) {
                        setModalState(() => errorText = null);
                      }
                    },
                    onSubmitted: (_) => addValue(),
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      errorText: errorText,
                      suffixIcon: IconButton(
                        tooltip: 'Add',
                        onPressed: addValue,
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
                if (values.isEmpty)
                  Expanded(
                    child: AlertMessage(
                      message: widget.emptyMessage,
                      vertical: true,
                    ),
                  )
                else
                  Expanded(
                    child: FrostyScrollbar(
                      child: ListView.builder(
                        itemCount: values.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(values.elementAt(index)),
                            trailing: IconButton(
                              tooltip: 'Remove',
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () => removeValue(index),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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

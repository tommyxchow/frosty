import 'package:flutter/widgets.dart';

class ChatMessage extends StatelessWidget {
  final List<InlineSpan> children;

  const ChatMessage({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: children,
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

class ChatMessage extends StatelessWidget {
  List<InlineSpan> children;

  ChatMessage({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RichText(
        text: TextSpan(
          children: children,
        ),
      ),
    );
  }
}

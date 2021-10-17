class IRCMessage {
  final Map<String, String> tags;
  final String command;
  final String? user;
  String? message;

  IRCMessage({required this.tags, required this.command, required this.user, required this.message});
}

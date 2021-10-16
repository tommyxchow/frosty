class IrcMessage {
  final Map<String, String> tags;
  final String command;
  final String? user;
  final String? message;

  const IrcMessage({required this.tags, required this.command, required this.user, required this.message});
}

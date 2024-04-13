class MessageReply {
  final String message;
  final String username;
  final String messageType;
  final bool isMe;

  MessageReply(
      {required this.message,
      required this.username,
      required this.messageType,
      required this.isMe});
}

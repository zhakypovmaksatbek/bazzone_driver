class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.isFromUser,
  });

  final String id;
  final String text;
  final DateTime sentAt;
  final bool isFromUser;
}

class SupportChatPreview {
  const SupportChatPreview({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
}

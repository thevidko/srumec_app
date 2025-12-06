class ChatMessage {
  final String id;
  final String roomId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      roomId: json['room_ref'] ?? '',
      authorId: json['user_ref'] ?? '',
      content: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['sent_time'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false, //TODO změnit podle toho co api pošle
    );
  }
}

class Comment {
  final String id;
  final String eventId;
  final String userId; // ID autora
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      eventId: json['event_ref'] ?? '',
      userId: json['user_ref'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['create_time'] ?? '') ?? DateTime.now(),
    );
  }
}
